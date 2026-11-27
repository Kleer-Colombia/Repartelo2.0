require 'rails_helper'
require 'support/sales_invoice_helpers'

describe FindAvailableInvoices do
  def numbers
    command = FindAvailableInvoices.new(sync: false).call
    expect(command).to be_success
    command.result[:invoices].map { |invoice| invoice[:number] }
  end

  it 'muestra las de los últimos 12 meses no anuladas y no usadas al 100%' do
    create_sales_invoice('A1')
    create_sales_invoice('A2', annulled_by: 'Nota crédito 1')
    create_sales_invoice('A3', issue_date: Date.current - 400)
    used = create_sales_invoice('A4')
    use_in_balance(create_balance, used, percentage: 100)

    expect(numbers).to eq ['A1']
  end

  it 'incluye las usadas en parte aunque sean viejas, con el porcentaje usado' do
    old = create_sales_invoice('B1', issue_date: Date.current - 600)
    use_in_balance(create_balance, old, percentage: 40)

    result = FindAvailableInvoices.new(sync: false).call.result[:invoices]
    expect(result.map { |i| [i[:number], i[:percentageUsed]] }).to eq [['B1', 40.0]]
  end
end
