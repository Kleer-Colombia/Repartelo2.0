# Migración única (re-ejecutable) de Alegra a las facturas del Drive:
#
# 1. Completa invoices.number (el número de factura, ej. FEKL10758) a
#    partir del id de Alegra que guardaban los balances.
# 2. Para cada factura ya traída del Drive, toma su estado en Alegra:
#    - abierta  → queda pendiente en Pagos (con las retenciones de Alegra
#                 como sugerencia para el formulario);
#    - cerrada  → se marca pagada, con las retenciones que tenía Alegra;
#    - anulada  → se marca anulada.
#    Las facturas que no están en Alegra (ej. ya emitidas en Contapyme)
#    quedan pendientes. No pisa pagos ya cargados en Pagos.
#
# Correr después de la carga completa del Drive (facturas:sync_drive_full).
class MigrateFromAlegra
  def initialize(client: AlegraClient.new, out: $stdout)
    @client = client
    @out = out
  end

  def call
    alegra = load_alegra
    @out.puts "Alegra: #{alegra.size} facturas leídas"
    map_balance_invoices(alegra)
    apply_statuses(alegra.values.index_by { |data| data[:number] })
    report_open_missing_in_drive(alegra.values)
  end

  private

  def load_alegra
    @client.each_invoice.each_with_object({}) do |invoice, by_id|
      template = invoice['numberTemplate'] || {}
      number = template['fullNumber'].presence || "#{template['prefix']}#{template['number']}"
      by_id[invoice['id'].to_i] = {
        number: number,
        status: invoice['status'],
        total_paid: invoice['totalPaid'].to_f,
        retentions: retentions(invoice['retentions'])
      }
    end
  end

  def retentions(list)
    (list || []).each_with_object({}) do |retention, result|
      kind = SalesInvoice.retention_kind_for(retention['name'])
      result[kind] = (result[kind] || 0) + retention['amount'].to_f
    end
  end

  # Abiertas en Alegra sin XML en el Drive: no van a aparecer en Pagos ni en
  # "Buscar factura" hasta que Administración suba el XML.
  def report_open_missing_in_drive(invoices)
    open_numbers = invoices.select { |data| data[:status] == 'open' }.map { |data| data[:number] }
    missing = open_numbers - SalesInvoice.where(number: open_numbers).pluck(:number)
    @out.puts "Abiertas en Alegra que no están en el Drive (falta el XML): #{missing.sort.inspect}" if missing.any?
  end

  def map_balance_invoices(alegra)
    mapped = 0
    missing = []
    Invoice.where(number: nil).where.not(alegra_id: nil).find_each do |invoice|
      data = alegra[invoice.alegra_id.to_i]
      if data && data[:number].present?
        invoice.update_columns(number: data[:number])
        mapped += 1
      else
        missing << invoice.alegra_id.to_i
      end
    end
    @out.puts "Balances: #{mapped} facturas pasaron a identificarse por número"
    @out.puts "  Sin correspondencia en Alegra (quedan sin número): #{missing.uniq.sort.inspect}" if missing.any?
  end

  def apply_statuses(by_number)
    counts = Hash.new(0)
    SalesInvoice.includes(:payment).find_each do |invoice|
      data = by_number[invoice.number]
      unless data
        counts['no está en Alegra (queda pendiente)'] += 1
        next
      end

      changes = { alegra_status: data[:status] }
      changes[:suggested_retentions] = data[:retentions] if invoice.suggested_retentions.blank? && data[:retentions].any?
      invoice.update_columns(changes)

      case data[:status]
      when 'closed'
        if invoice.payment
          counts['cerrada, ya tenía pago'] += 1
        else
          invoice.create_payment!(source: 'alegra', amount: data[:total_paid].positive? ? data[:total_paid] : nil,
                                  **data[:retentions].symbolize_keys)
          counts['cerrada → pagada'] += 1
        end
      when 'void'
        invoice.update_columns(annulled_by: 'Anulada en Alegra') unless invoice.annulled?
        counts['anulada en Alegra'] += 1
      else
        counts["#{data[:status]} → pendiente"] += 1
      end
    end
    counts.sort.each { |label, count| @out.puts "  #{label}: #{count}" }
  end
end
