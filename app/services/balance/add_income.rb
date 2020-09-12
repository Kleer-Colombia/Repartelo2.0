class AddIncome

  prepend ComposedService

  def initialize(balance_id, service_income)
    is_invoice = service_income['invoiceId']
    invoice_percentage = service_income['invoicePercentageToUse'] || 100
    balance = Balance.find(balance_id)
    add_service(CreateIncome.new(balance: balance,
                                 income: service_income,
                                 is_invoice: is_invoice,
                                 invoice_percentage: invoice_percentage))
    if is_invoice
      add_service(CalculateTaxesInInvoice.new(balance: balance,
                                              alegra_invoice: Service::INSPECT,
                                              invoice: Service::INSPECT,
                                              trm: service_income['trm']))
    end
  end

  def call
    @results[CreateIncome]
  end
end