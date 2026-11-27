require 'rails_helper'

describe DriveInvoiceSync do
  # Drive falso en memoria: {id_carpeta => [Entry]} y {id_archivo => bytes}.
  class FakeDrive
    attr_reader :listed

    def initialize(tree, files)
      @tree = tree
      @files = files
      @listed = []
    end

    def list(id)
      @listed << id
      @tree.fetch(id, [])
    end

    def download(id)
      @files.fetch(id)
    end
  end

  def folder(id, name)
    DriveFolderClient::Entry.new(id, name, true)
  end

  def file(id, name)
    DriveFolderClient::Entry.new(id, name, false)
  end

  let(:invoice_xml) { file_fixture('dian/attached_invoice.xml').read }
  let(:other_supplier_xml) { invoice_xml.sub('900957609', '811111111').sub('TEST900', 'OTRO1') }
  let(:tree) do
    {
      'ROOT' => [folder('Y2026', '2026'), folder('Y2015', '2015')],
      'Y2026' => [folder('VENTAS', 'Facturas de venta'), folder('NC', 'Notas Crédito'), folder('GASTOS', 'Gastos')],
      'VENTAS' => [folder('NOV', '11. Noviembre')],
      'NOV' => [folder('F900', 'TEST900 - Cliente'), folder('FOTRO', 'Otro emisor')],
      'F900' => [file('X900', 'Factura TEST900.xml'), file('P900', 'Factura TEST900.pdf')],
      'FOTRO' => [file('XOTRO', 'Factura OTRO1.xml')],
      'NC' => [file('NC1', '2026-11-10 Nota credito No. 1.pdf')],
      'GASTOS' => [file('G1', 'gasto.xml')]
    }
  end
  let(:files) { { 'X900' => invoice_xml, 'XOTRO' => other_supplier_xml, 'NC1' => '%PDF-falso' } }
  let(:drive) { FakeDrive.new(tree, files) }

  around do |example|
    previous = ENV[DriveInvoiceSync::ROOT_ENV]
    ENV[DriveInvoiceSync::ROOT_ENV] = 'ROOT'
    example.run
    ENV[DriveInvoiceSync::ROOT_ENV] = previous
  end

  before do
    allow(CreditNoteReader).to receive(:references).with('%PDF-falso')
                                                   .and_return('cufes' => ['a' * 96], 'numbers' => [])
  end

  def sync(mode = 'incremental')
    DriveInvoiceSync.new(mode: mode, client: drive, today: Date.new(2026, 11, 27)).call
  end

  it 'trae las facturas de Kleer y marca anuladas las citadas por notas crédito' do
    run = sync

    expect(run.error).to be_nil
    invoice = SalesInvoice.find_by!(number: 'TEST900')
    expect(invoice.drive_path).to eq '2026/Facturas de venta/11. Noviembre/TEST900 - Cliente'
    expect(invoice.annulled_by).to eq '2026-11-10 Nota credito No. 1.pdf'
    expect(invoice.annulled_on).to eq Date.new(2026, 11, 10)
    expect(invoice.suggested_retentions).to eq('retefuente' => 99.0)
    expect(SalesInvoice.where(number: 'OTRO1')).to be_empty
    expect(DriveFile.find_by(drive_id: 'XOTRO').error).to include('no es Kleer')
    expect(run.summary).to include('new_invoices' => 1, 'credit_notes' => 1, 'annulled' => 1)
  end

  it 'en modo incremental solo recorre el año actual y el anterior, y no la carpeta Gastos' do
    sync
    expect(drive.listed).not_to include('Y2015', 'GASTOS')
  end

  it 'no vuelve a listar carpetas de facturas ya leídas ni a descargar archivos ya procesados' do
    sync
    drive.listed.clear
    expect(drive).not_to receive(:download)

    sync

    expect(drive.listed).not_to include('F900')
    expect(drive.listed).to include('NOV')
  end

  it 'deja registrado el error de un XML ilegible y lo reintenta en la próxima corrida' do
    files['X900'] = '<roto'
    run = sync
    expect(run.summary['errors'].first['where']).to include('Factura TEST900.xml')
    expect(DriveFile.find_by(drive_id: 'X900').status).to eq 'error'

    files['X900'] = invoice_xml
    sync
    expect(SalesInvoice.find_by(number: 'TEST900')).to be_present
  end

  it 'run_if_stale no sincroniza si la última corrida es reciente' do
    DriveSyncRun.create!(mode: 'incremental', started_at: 1.minute.ago, finished_at: 1.minute.ago)
    expect(DriveInvoiceSync).not_to receive(:new)
    DriveInvoiceSync.run_if_stale
  end
end
