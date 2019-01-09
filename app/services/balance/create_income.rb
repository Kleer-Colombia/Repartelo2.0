class CreateIncome
  prepend Service
  attr_accessor :balance_id, :income, :invoice_date, :is_invoice, :invoice_id

  def initialize(data)
    @balance_id = data[:balance_id]
    @income = data[:income]
    @invoice_date = Time.now
    @invoice_id = ''
    @is_invoice = data[:is_invoice]
  end

  def call
    balance = Balance.find(@balance_id)
    get_data_from_invoice if @is_invoice

    balance.incomes.create!(description: @income[:description],
                            amount: @income[:amount],
                            invoice_date: @invoice_date,
                            invoice_id: @invoice_id)

    return {incomes: balance.incomes,
            total: balance.total_incomes}

  rescue StandardError => error
    errors.add(:messages, "error adding incomes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def get_data_from_invoice
    invoice = AlegraConnector.get_invoice(@income['invoiceId'])
    up_parameter(:invoice, invoice)
    @invoice_date = invoice['date']
    @invoice_id = invoice['id']

  end
end