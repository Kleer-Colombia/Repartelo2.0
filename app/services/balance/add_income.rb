class AddIncome

  prepend ComposedService

  def initialize(balance_id, income)
    is_invoice = income['invoiceId']
    balance = Balance.find(balance_id)
    add_service(CreateIncome.new(balance: balance,
                                 income: income,
                                 is_invoice: is_invoice))
    if is_invoice
      add_service(CalculateTaxesInInvoice.new(balance: balance,
                                              invoice: Service::INSPECT))
    end
  end

  def call
    @results[CreateIncome]
  end
end