class AddIncome

  prepend ComposedService

  def initialize(balance_id, income)
    is_invoice = income['invoiceId']
    invoice_percentage = income['invoicePercentageToUse'] || 100
    balance = Balance.find(balance_id)
    add_service(CreateIncome.new(balance: balance,
                                 income: income,
                                 is_invoice: is_invoice,
                                 invoice_percentage: invoice_percentage))
    if is_invoice
      add_service(CalculateTaxesInInvoice.new(balance: balance,
                                              invoice: Service::INSPECT,
                                              invoice_percentage: Service::INSPECT))
    end
  end

  def call
    @results[CreateIncome]
  end
end