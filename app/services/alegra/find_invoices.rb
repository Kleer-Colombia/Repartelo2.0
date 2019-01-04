class FindInvoices
  prepend Service

  attr_reader :status

  def initialize(data)
    @status = data[:status]
  end

  def call
    invoices = AlegraConnector.get_invoices(@status)
    invoices = remove_invoice_in_balances(invoices)
    remove_unnecessary_data(invoices)
  rescue StandardError => error
    errors.add(:messages, "error getting invoice: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def remove_invoice_in_balances(invoices)
    #optimize with balance editable
    incomes = Income.where.not(invoice_id: nil)
    invoice_ids = incomes.map{ |income| income.invoice_id }
    invoices_to_remove = invoices.select{ |invoice| invoice_ids.include?(invoice['id'].to_i)}
    invoices = invoices - invoices_to_remove
    invoices
  end

  def remove_unnecessary_data(invoices)
    invoices.each do |invoice|
      invoice.delete('observations')
      invoice.delete('anotation')
      invoice.delete('termsConditions')
      invoice.delete('numberTemplate')
      invoice.delete('warehouse')
      invoice.delete('seller')
      invoice.delete('priceList')
      remove_client_data(invoice)
      invoice.delete('items')
    end
  end

  def remove_client_data(invoice)
    invoice['client'].delete('identification')
    invoice['client'].delete('phonePrimary')
    invoice['client'].delete('phoneSecondary')
    invoice['client'].delete('fax')
    invoice['client'].delete('mobile')
    invoice['client'].delete('email')
    invoice['client'].delete('regime')
    invoice['client'].delete('identificationObject')
    invoice['client'].delete('address')
    invoice['client'].delete('kindOfPerson')
  end
end