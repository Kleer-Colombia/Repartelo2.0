require 'rails_helper'
require 'support/sales_invoice_helpers'

describe 'Pagos de facturas' do
  let(:user) { double(name: 'Ginneth') }
  let(:payment_data) do
    { 'paidOn' => '2026-11-20', 'amount' => '1069000', 'retefuente' => '110000', 'reteica' => '11000', 'reteiva' => '0' }
  end

  def register(number, data = payment_data)
    RegisterPayment.new(number: number, data: data, user: user).call
  end

  it 'lista como pendientes las facturas no anuladas sin pago' do
    create_sales_invoice('P1')
    create_sales_invoice('P2', annulled_by: 'NC 1')
    paid = create_sales_invoice('P3')
    paid.create_payment!(paid_on: Date.current, amount: 1, source: 'repartelo')

    result = FindPayments.new(status: 'pending', sync: false).call.result
    expect(result[:invoices].map { |i| i[:number] }).to eq ['P1']
  end

  it 'registra el pago con fecha, monto y retenciones' do
    create_sales_invoice('P1')
    command = register('P1')

    expect(command).to be_success
    payment = SalesInvoice.find_by(number: 'P1').payment
    expect(payment.paid_on).to eq Date.new(2026, 11, 20)
    expect(payment.amount).to eq 1_069_000
    expect(payment.retentions).to eq('retefuente' => 110_000.0, 'reteica' => 11_000.0, 'reteiva' => 0.0)
    expect(payment.registered_by).to eq 'Ginneth'
  end

  it 'exige fecha y monto' do
    create_sales_invoice('P1')
    command = register('P1', 'retefuente' => '10')
    expect(command).not_to be_success
    expect(SalesInvoice.find_by(number: 'P1').payment).to be_nil
  end

  it 'aplica las retenciones (prorrateadas) en los balances abiertos que usan la factura' do
    invoice = create_sales_invoice('P1')
    balance = create_balance
    use_in_balance(balance, invoice, percentage: 50)

    command = register('P1', payment_data.merge('reteiva' => '20000'))

    expect(command.result[:updatedBalances]).to eq [balance.id]
    taxes = balance.reload.taxes.where.not(invoice_id: nil).pluck(:name, :amount).to_h
    expect(taxes).to eq('RETEFUENTE' => 55_000, 'RETEICA' => 5_500, 'RETEIVA' => -10_000)
  end

  it 'al corregir el pago reemplaza las retenciones, también las que venían de Alegra' do
    invoice = create_sales_invoice('P1')
    balance = create_balance
    item = use_in_balance(balance, invoice)
    Tax.create!(balance: balance, invoice: item, name: 'IVA', amount: 190_000, percentage: 19)
    Tax.create!(balance: balance, invoice: item, name: 'RETEFUENTE (Honorarios y comisiones)', amount: 1, percentage: 11)

    register('P1')

    names = balance.reload.taxes.where(invoice_id: item.id).pluck(:name)
    expect(names).to contain_exactly('IVA', 'RETEFUENTE', 'RETEICA')
  end

  it 'no deja cambiar ni borrar el pago de una factura usada en un balance cerrado' do
    invoice = create_sales_invoice('P1')
    invoice.create_payment!(paid_on: Date.current, amount: 1, source: 'repartelo')
    use_in_balance(create_balance(editable: false), invoice)

    expect(register('P1')).not_to be_success
    expect(RemovePayment.new(number: 'P1').call).not_to be_success
  end

  it 'desmarcar el pago saca las retenciones de los balances abiertos' do
    invoice = create_sales_invoice('P1')
    balance = create_balance
    use_in_balance(balance, invoice)
    register('P1')

    expect(RemovePayment.new(number: 'P1').call).to be_success
    expect(invoice.reload.payment).to be_nil
    expect(balance.reload.taxes.where(name: %w[RETEFUENTE RETEICA])).to be_empty
  end
end
