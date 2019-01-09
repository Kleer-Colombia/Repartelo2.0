class AddIncome

  prepend ComposedService

  def initialize(balance_id, income)
    is_invoice = income['invoiceId']
    add_service(CreateIncome.new(balance_id: balance_id,
                                 income: income,
                                 is_invoice: is_invoice))
    add_service(CalculateTaxesInInvoice.new(balance_id: balance_id,
                                            invoice: Service::INSPECT)) if is_invoice
  end

  def call
    @results[CreateIncome]
  end
end