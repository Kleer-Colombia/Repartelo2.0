require 'rails_helper'
require 'support/sales_invoice_helpers'

# La tabla de distribución tiene que coincidir con la utilidad (+ lo que
# KleerCo cobra sobre los clearings) para poder enviar a saldos.
describe 'Distribución al enviar a saldos' do
  before do
    TaxMaster.delete_all
    TaxMaster.create!(name: 'IVA', value: 19, type_tax: 'in_alegra')
    TaxMaster.create!(name: 'Utilidad', value: 20, type_tax: 'utility')
    TaxMaster.create!(name: 'kleerCo', value: 10, type_tax: 'post_utility')
    TaxMaster.create!(name: 'Clearing', value: 5, type_tax: 'clearing')
    Kleerer.find_or_create_by!(name: 'KleerCo') { |k| k.option = Option.create!(name: 'Home', value: 0) }
    socio = Kleerer.create!(name: 'socio-dist', option: Option.create!(name: 'Socio', value: 5))
    balance.percentages.create!(kleerer: socio, value: 100)
    create_sales_invoice('D1', subtotal: 1_000_000)
    AddIncome.new(balance.id, { 'description' => 'Factura D1', 'amount' => 1_190_000, 'invoiceId' => 'D1',
                                'invoicePercentageToUse' => 100, 'trm' => 1 }.with_indifferent_access).call
    CalculateTaxes.for_balance(balance.reload).call
  end

  let(:balance) { create_balance }

  def distribute
    expect(DistributeBalance.new(balance_id: balance.id).call).to be_success
  end

  def pay(retefuente)
    RegisterPayment.new(number: 'D1', data: { 'paidOn' => '2026-11-20', 'amount' => '1000000',
                                              'retefuente' => retefuente.to_s }).call
  end

  it 'recién distribuido, la tabla coincide con la utilidad' do
    distribute
    check = balance.reload.distribution_check
    expect(check[:ok]).to be true
    expect(check[:distributed]).to be_within(1).of(check[:expected])
  end

  it 'si algo cambia después de distribuir, no deja enviar a saldos y explica por qué' do
    pay(0)
    distribute
    balance.expenses.create!(description: 'Gasto tardío', amount: 100_000)
    CalculateTaxes.for_balance(balance.reload).call

    command = CloseBalance.new(balance.id).call

    expect(command).not_to be_success
    expect(command.errors[:messages].first).to include('La distribución quedó desactualizada')
    expect(balance.reload.editable).to be true

    distribute
    expect(CloseBalance.new(balance.id).call).to be_success
  end

  it 'sin distribuir, no deja enviar a saldos' do
    pay(0)
    command = CloseBalance.new(balance.id).call
    expect(command.errors[:messages].first).to include('Falta distribuir')
  end

  it 'cambiar la retención en Pagos vuelve a distribuir el balance' do
    pay(0)
    distribute
    before = balance.reload.distributions.sum(:amount)

    pay(110_000)

    balance.reload
    expect(balance.distribution_check[:ok]).to be true
    expect(balance.distributions.sum(:amount)).not_to eq before
    expect(CloseBalance.new(balance.id).call).to be_success
  end
end
