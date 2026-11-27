require 'rails_helper'
require 'support/sales_invoice_helpers'

describe MigrateFromAlegra do
  let(:alegra_invoices) do
    [
      { 'id' => 10, 'numberTemplate' => { 'fullNumber' => 'FEKL1' }, 'status' => 'closed', 'totalPaid' => 1_000,
        'retentions' => [{ 'name' => 'Honorarios y comisiones', 'amount' => '110' }, { 'name' => 'ReteIVA', 'amount' => '20' },
                         { 'name' => 'Reteica Bogotá 2022', 'amount' => '9' }] },
      { 'id' => 11, 'numberTemplate' => { 'fullNumber' => 'FEKL2' }, 'status' => 'open', 'totalPaid' => 0,
        'retentions' => [{ 'name' => 'Servicios en general', 'amount' => '40' }] },
      { 'id' => 12, 'numberTemplate' => { 'prefix' => nil, 'number' => '531' }, 'status' => 'closed', 'totalPaid' => 5 },
      { 'id' => 13, 'numberTemplate' => { 'fullNumber' => 'FEKL3' }, 'status' => 'void', 'totalPaid' => 0 }
    ]
  end
  let(:client) { double(each_invoice: alegra_invoices.each) }

  def run
    MigrateFromAlegra.new(client: client, out: StringIO.new).call
  end

  it 'pasa los balances de id de Alegra a número de factura' do
    income = create_balance.incomes.create!(description: 'Factura 531', amount: 1)
    legacy = Invoice.new(income: income, alegra_id: 12, date: Date.current, percentage: 100)
    legacy.save!(validate: false)

    run

    expect(legacy.reload.number).to eq '531'
  end

  it 'marca pagadas las cerradas (con sus retenciones), deja pendientes las abiertas y anula las anuladas' do
    %w[FEKL1 FEKL2 FEKL3 CONTA1].each { |number| create_sales_invoice(number) }

    run

    paid = SalesInvoice.find_by(number: 'FEKL1').payment
    expect([paid.source, paid.amount.to_f]).to eq ['alegra', 1000.0]
    expect(paid.retentions).to eq('retefuente' => 110.0, 'reteica' => 9.0, 'reteiva' => 20.0)

    open = SalesInvoice.find_by(number: 'FEKL2')
    expect(open.payment).to be_nil
    expect(open.suggested_retentions).to eq('retefuente' => 40.0)

    expect(SalesInvoice.find_by(number: 'FEKL3')).to be_annulled
    expect(SalesInvoice.find_by(number: 'CONTA1').payment).to be_nil
  end

  it 'es re-ejecutable y no pisa pagos cargados en Pagos' do
    invoice = create_sales_invoice('FEKL1')
    invoice.create_payment!(paid_on: Date.current, amount: 7, source: 'repartelo')

    run
    run

    expect(invoice.reload.payment.attributes.values_at('source', 'amount')).to eq ['repartelo', 7]
  end
end
