class CreateIncome
  prepend Service
  attr_accessor :balance, :income, :invoice_date, :is_invoice, :invoice_id, :alegraClient, :invoice_percentage

  def initialize(data)
    @balance = data[:balance]
    @income = data[:income]
    @invoice_date = Time.now
    @invoice_id = ''
    @invoice_percentage = data[:invoice_percentage]
    @is_invoice = data[:is_invoice]
    @alegraClient = AlegraClientFactory.build
  end

  def call
    income = @balance.incomes.create!(description: @income[:description],
                                      amount: @income[:amount])
    if @is_invoice
      get_data_from_invoice
      income.create_invoice!(income: income,
                             invoice_id: @invoice_id,
                             date: @invoice_date,
                             percentage: @invoice_percentage)
    end

    return {incomes: @balance.incomes,
            total: @balance.total_incomes}

  rescue StandardError => error
    errors.add(:messages, "error adding incomes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def get_data_from_invoice
    invoice = @alegraClient.get_invoice(@income['invoiceId'])
    @invoice_date = invoice['date']
    @invoice_id = invoice['id']
    set_parameter_for_other_services(invoice)
  end

  def set_parameter_for_other_services(invoice)
    up_parameter(:invoice, invoice)
    up_parameter(:invoice_percentage, @invoice_percentage)
  end
end