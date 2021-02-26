class CreateIncome
  prepend Service
  attr_accessor :balance, :service_income, :invoice_date, :is_invoice, :invoice_id, :alegraClient, :invoice_percentage

  def initialize(data)
    @balance = data[:balance]
    @service_income = data[:income]
    @invoice_date = Time.now
    @invoice_id = ''
    @invoice_percentage = data[:invoice_percentage]
    @is_invoice = data[:is_invoice]
    @alegraClient = AlegraClientFactory.build
  end

  def call
    Rails.logger.info("creating income")
    Rails.logger.info("service income: #{@service_income}")
    income = @balance.incomes.create!(description: @service_income[:description],
                                      amount: calculate_amount(@service_income[:amount]))
    if @is_invoice
      get_data_from_invoice

      income.create_invoice!(income: income,
                             invoice_id: @invoice_id,
                             date: @invoice_date,
                             percentage: @invoice_percentage)
      up_parameter(:invoice, income.invoice)
    end

    return {incomes: @balance.incomes,
            total: @balance.total_incomes}

  rescue StandardError => error
    errors.add(:messages, "error adding incomes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def get_data_from_invoice
    alegra_invoice = @alegraClient.get_invoice(@service_income['invoiceId'])
    @invoice_date = alegra_invoice['date']
    @invoice_id = alegra_invoice['id']
    up_parameter(:alegra_invoice, alegra_invoice)
  end


  def calculate_amount(amount)
    ((amount * @invoice_percentage.to_f)/100).round 2
  end
end