class FindInvoices
  prepend Service

  attr_reader :status, :alegraClient

  def initialize(data)
    @status = data[:status]
    @alegraClient = AlegraClientFactory.build
  end

  def call
    invoices = @alegraClient.get_invoices(@status)
    invoices = remove_the_invoices_in_balances(invoices)
    remove_unnecessary_data(invoices)
  rescue StandardError => error
    puts "An error of type #{error.class} happened, message is #{error.message}"
    errors.add(:messages, "error getting invoice: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def remove_the_invoices_in_balances(invoices)
    invoice_candidates_ids = Invoice.where(percentage: 100).map{ |invoice| invoice.invoice_id }
    invoices_to_remove = invoices.select{ |invoice| invoice_candidates_ids.include?(invoice['id'].to_i)}
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