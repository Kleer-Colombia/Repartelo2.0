require 'set'

# Trae al sistema las facturas de venta (y las notas crédito que las anulan)
# que están en el Drive de contabilidad y todavía no se cargaron.
#
# Estructura esperada (la que arma Administración):
#   <carpeta raíz> / <año> / Facturas de venta / <mes> / <factura> / *.xml
#   <carpeta raíz> / <año> / Notas crédito / *.pdf|*.xml
# Los nombres de meses y de carpetas de cada factura no importan: se
# recorre todo lo que hay debajo de cada sección y se lee el contenido de
# los XML, no los nombres de archivo.
#
# Modos:
#   incremental: solo el año actual y el anterior, y no vuelve a listar las
#                carpetas de facturas ya leídas. Es lo que se usa al consultar.
#   full:        todos los años y todas las carpetas (carga inicial).
class DriveInvoiceSync
  ROOT_ENV = 'DRIVE_CONTABILIDAD_FOLDER_ID'.freeze
  KLEER_NIT_ENV = 'KLEER_NIT'.freeze
  DEFAULT_KLEER_NIT = '900957609'.freeze
  STALE_AFTER = 10.minutes
  THREADS = 6
  LOCK_KEY = 72_633_001
  MAX_ERRORS_IN_SUMMARY = 20

  SECTIONS = {
    invoice: /\Afacturas( de venta)?\z/i,
    credit_note: /\Anotas? cr[eé]dito\z/i
  }.freeze

  def self.folder_id
    ENV[ROOT_ENV].presence
  end

  def self.configured?
    folder_id.present?
  end

  # Para consultas desde la app: sincroniza solo si la última corrida tiene
  # más de STALE_AFTER. Devuelve la corrida (nueva o la última) o nil si el
  # Drive no está configurado.
  def self.run_if_stale
    return nil unless configured?

    last = DriveSyncRun.last_finished
    return last if last && last.finished_at > STALE_AFTER.ago

    new(mode: 'incremental').call
  end

  def initialize(mode: 'incremental', client: DriveFolderClient.new, today: Date.current)
    raise ArgumentError, "modo inválido: #{mode}" unless %w[incremental full].include?(mode)

    @mode = mode
    @client = client
    @today = today
    @mutex = Mutex.new
    @summary = { 'folders_listed' => 0, 'files_downloaded' => 0, 'new_invoices' => 0,
                 'updated_invoices' => 0, 'credit_notes' => 0, 'annulled' => 0, 'errors' => [] }
  end

  def call
    raise "Falta la variable #{ROOT_ENV} (id de la carpeta de Contabilidad)" unless self.class.configured?

    run = DriveSyncRun.create!(mode: @mode, started_at: Time.current)
    locked = with_advisory_lock do
      sync_tree
      resolve_credit_notes
    end
    @summary['skipped'] = 'otra sincronización en curso' unless locked
    run.update!(finished_at: Time.current, summary: @summary)
    run
  rescue StandardError => e
    Rails.logger.error("[DriveInvoiceSync] #{e.class}: #{e.message}")
    run&.update(finished_at: Time.current, summary: @summary, error: e.message)
    run || raise
  end

  private

  def with_advisory_lock
    connection = ActiveRecord::Base.connection
    return false unless connection.select_value("SELECT pg_try_advisory_lock(#{LOCK_KEY})")

    begin
      yield
      true
    ensure
      connection.execute("SELECT pg_advisory_unlock(#{LOCK_KEY})")
    end
  end

  def sync_tree
    @known = DriveFile.where(status: %w[processed ignored done]).pluck(:drive_id).to_set
    years = list(self.class.folder_id).select { |e| e.folder? && e.name.strip =~ /\A\d{4}\z/ }
    years = years.select { |e| [@today.year, @today.year - 1].include?(e.name.to_i) } if @mode == 'incremental'

    years.sort_by(&:name).each do |year|
      list(year.id).select(&:folder?).each do |section|
        kind = SECTIONS.find { |_, pattern| section.name.strip =~ pattern }&.first
        walk(section, kind, "#{year.name}/#{section.name}") if kind
      end
    end
  end

  # Recorre la sección por niveles, listando varias carpetas a la vez.
  def walk(section, kind, path)
    pending = [[section, path]]
    until pending.empty?
      batch = pending.shift(THREADS)
      parallel(batch) { |folder, folder_path| [folder, folder_path, safe_list(folder, folder_path)] }.each do |folder, folder_path, entries|
        next if entries.nil?

        entries.select(&:folder?).each do |sub|
          next if @mode == 'incremental' && @known.include?(sub.id)

          pending << [sub, "#{folder_path}/#{sub.name}"]
        end
        process_files(folder, folder_path, entries.reject(&:folder?), kind)
      end
    end
  end

  def process_files(folder, path, files, kind)
    candidates = files.select { |f| relevant?(f, kind) }
    new_files = candidates.reject { |f| @known.include?(f.id) }
    downloads = parallel(new_files) { |file| [file, safe_download(file, path)] }

    downloads.each do |file, bytes|
      next if bytes.nil?

      begin
        process(file, bytes, path, kind)
      rescue DianDocumentParser::Error, Nokogiri::SyntaxError, ActiveRecord::RecordInvalid, ArgumentError => e
        record_error(file, path, kind, e)
      end
    end

    mark_folder_done(folder, path, files) if kind == :invoice
  end

  def relevant?(file, kind)
    return file.extension == 'xml' if kind == :invoice

    %w[xml pdf].include?(file.extension)
  end

  # Una carpeta de factura ya leída (sin subcarpetas y con su XML procesado)
  # no se vuelve a listar en modo incremental.
  def mark_folder_done(folder, path, files)
    xml_ids = files.select { |f| f.extension == 'xml' }.map(&:id)
    return if xml_ids.empty?
    return unless DriveFile.where(drive_id: xml_ids, status: %w[processed ignored]).count == xml_ids.size

    upsert_file(folder.id, name: folder.name, path: path, kind: 'folder', status: 'done')
  end

  def process(file, bytes, path, section_kind)
    if file.extension == 'pdf'
      return record_credit_note(file, path, CreditNoteReader.references(bytes))
    end

    result = DianDocumentParser.parse(bytes)
    case result.kind
    when :invoice then record_invoice(file, path, result.attributes)
    when :credit_note then record_credit_note(file, path, result.references)
    else upsert_file(file.id, name: file.name, path: path, kind: kind_for(section_kind), status: 'ignored',
                              error: 'no es factura ni nota crédito')
    end
  end

  def record_invoice(file, path, attrs)
    supplier = attrs.delete(:supplier_nit).to_s
    unless supplier.start_with?(kleer_nit)
      return upsert_file(file.id, name: file.name, path: path, kind: 'invoice_xml', status: 'ignored',
                                  error: "emisor #{supplier} no es Kleer")
    end

    suggested = attrs.delete(:suggested_retentions)
    invoice = SalesInvoice.find_or_initialize_by(number: attrs[:number])
    if invoice.persisted? && invoice.drive_file_id.present? && invoice.drive_file_id != file.id
      return upsert_file(file.id, name: file.name, path: path, kind: 'invoice_xml', status: 'ignored',
                                  error: "duplicado de #{invoice.number} (#{invoice.drive_path})")
    end

    was_new = invoice.new_record?
    invoice.assign_attributes(attrs.merge(drive_file_id: file.id, drive_path: path))
    invoice.suggested_retentions = suggested if suggested.present? && invoice.suggested_retentions.blank?
    invoice.save!
    @summary[was_new ? 'new_invoices' : 'updated_invoices'] += 1
    upsert_file(file.id, name: file.name, path: path, kind: 'invoice_xml', status: 'processed', sales_invoice: invoice)
  end

  def record_credit_note(file, path, refs)
    @summary['credit_notes'] += 1
    upsert_file(file.id, name: file.name, path: path, kind: 'credit_note', status: 'processed', doc_refs: refs)
  end

  # Marca como anuladas las facturas citadas por alguna nota crédito. Se
  # corre siempre (no solo con notas nuevas) porque la nota puede haber
  # llegado antes que la factura.
  def resolve_credit_notes
    DriveFile.credit_notes.where(sales_invoice_id: nil).find_each do |note|
      refs = note.doc_refs || {}
      invoice = SalesInvoice.find_by(cufe: refs['cufes']) if refs['cufes'].present?
      invoice ||= SalesInvoice.find_by(number: refs['numbers']) if refs['numbers'].present?
      next unless invoice

      unless invoice.annulled?
        invoice.update!(annulled_by: note.name, annulled_on: note.name.to_s[/\A\d{4}-\d{2}-\d{2}/]&.to_date)
        @summary['annulled'] += 1
      end
      note.update!(sales_invoice: invoice)
    end
  end

  def kind_for(section_kind)
    section_kind == :invoice ? 'invoice_xml' : 'credit_note'
  end

  def kleer_nit
    ENV[KLEER_NIT_ENV].presence || DEFAULT_KLEER_NIT
  end

  def upsert_file(drive_id, attrs)
    record = DriveFile.find_or_initialize_by(drive_id: drive_id)
    record.assign_attributes({ error: nil }.merge(attrs))
    record.save!
    @known << drive_id if %w[processed ignored done].include?(record.status)
    record
  end

  def record_error(file, path, kind, error)
    message = "#{error.class}: #{error.message}".truncate(500)
    Rails.logger.warn("[DriveInvoiceSync] #{path}/#{file.name}: #{message}")
    upsert_file(file.id, name: file.name, path: path, kind: kind_for(kind), status: 'error', error: message)
    add_summary_error("#{path}/#{file.name}", message)
  end

  def add_summary_error(where, message)
    @mutex.synchronize do
      @summary['errors'] << { 'where' => where, 'message' => message } if @summary['errors'].size < MAX_ERRORS_IN_SUMMARY
    end
  end

  def bump(key)
    @mutex.synchronize { @summary[key] += 1 }
  end

  def list(folder_id)
    bump('folders_listed')
    @client.list(folder_id)
  end

  def safe_list(folder, path)
    list(folder.id)
  rescue DriveFolderClient::Error, SocketError, Timeout::Error, SystemCallError, OpenSSL::SSL::SSLError => e
    add_summary_error(path, "no se pudo listar: #{e.message}")
    nil
  end

  def safe_download(file, path)
    bytes = @client.download(file.id)
    bump('files_downloaded')
    bytes
  rescue DriveFolderClient::Error, SocketError, Timeout::Error, SystemCallError, OpenSSL::SSL::SSLError => e
    add_summary_error("#{path}/#{file.name}", "no se pudo descargar: #{e.message}")
    nil
  end

  # Solo HTTP en los hilos; las escrituras a la base quedan en el hilo
  # principal (los contadores del resumen usan @mutex). Mientras se espera
  # a los hilos se permite que otros carguen constantes, para no trabar el
  # autoloader de desarrollo.
  def parallel(items)
    results = []
    items.each_slice(THREADS) do |slice|
      threads = slice.map { |item| Thread.new { yield(item) } }
      ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
        results.concat(threads.map(&:value))
      end
    end
    results
  end
end
