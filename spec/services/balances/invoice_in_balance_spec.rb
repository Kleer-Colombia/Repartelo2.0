require 'rails_helper'
require 'support/sales_invoice_helpers'

describe 'Factura en un balance' do
  let(:balance) { create_balance }

  def add_invoice(number, percentage: 100, trm: 1)
    AddIncome.new(balance.id, { 'description' => "Factura #{number}", 'amount' => 1_190_000,
                                'invoiceId' => number, 'invoicePercentageToUse' => percentage, 'trm' => trm }.with_indifferent_access).call
  end

  it 'guarda la factura por número y toma el IVA de los ítems' do
    create_sales_invoice('F1')
    command = add_invoice('F1', percentage: 50)

    expect(command).to be_success
    invoice = balance.incomes.first.invoice
    expect([invoice.number, invoice.percentage.to_f]).to eq ['F1', 50.0]
    expect(balance.reload.taxes.pluck(:name, :amount)).to eq [['IVA', 95_000]]
  end

  it 'si la factura ya está pagada, agrega sus retenciones' do
    create_sales_invoice('F1').create_payment!(paid_on: Date.current, amount: 1, retefuente: 110_000, source: 'repartelo')
    add_invoice('F1')

    expect(balance.reload.taxes.pluck(:name, :amount)).to contain_exactly(['IVA', 190_000], ['RETEFUENTE', 110_000])
  end

  it 'no deja usar más del 100% de una factura ni una anulada' do
    create_sales_invoice('F1')
    create_sales_invoice('F2', annulled_by: 'NC 1')
    add_invoice('F1', percentage: 70)

    expect(add_invoice('F1', percentage: 40)).not_to be_success
    expect(add_invoice('F2')).not_to be_success
  end

  describe CloseBalance do
    before { TaxMaster.find_or_create_by!(name: 'Clearing') { |t| t.value = 5; t.type_tax = 'post_utility' } }

    it 'no cierra el balance si alguna factura no está pagada en Pagos' do
      use_in_balance(balance, create_sales_invoice('F1'))
      command = CloseBalance.new(balance.id).call

      expect(command).not_to be_success
      expect(command.errors[:messages].first).to include('F1')
      expect(balance.reload.editable).to be true
    end

    it 'una factura anulada bloquea el cierre con un mensaje para sacarla' do
      use_in_balance(balance, create_sales_invoice('F1', annulled_by: 'NC 1'))
      command = CloseBalance.new(balance.id).call

      expect(command).not_to be_success
      expect(command.errors[:messages].first).to include('sacalas del balance: F1')
    end

    it 'una factura de la época de Alegra que no está en el Drive no bloquea el cierre' do
      income = balance.incomes.create!(description: 'Factura 531', amount: 1)
      Invoice.new(income: income, alegra_id: 531, date: Date.current, percentage: 100).save!(validate: false)

      expect(CloseBalance.new(balance.id).call).to be_success
    end

    it 'cierra el balance cuando todas sus facturas están pagadas' do
      invoice = create_sales_invoice('F1')
      invoice.create_payment!(paid_on: Date.current, amount: 1, source: 'repartelo')
      use_in_balance(balance, invoice)

      expect(CloseBalance.new(balance.id).call).to be_success
      expect(balance.reload.editable).to be false
    end
  end
end
