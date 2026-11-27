class CreateIncome
  prepend Service
  attr_accessor :balance, :service_income, :is_invoice, :invoice_percentage

  def initialize(data)
    @balance = data[:balance]
    @service_income = data[:income]
    @invoice_percentage = data[:invoice_percentage]
    @is_invoice = data[:is_invoice]
  end

  def call
    Rails.logger.info("creating income")
    Rails.logger.info("service income: #{@service_income}")
    sales_invoice = find_sales_invoice if @is_invoice

    income = @balance.incomes.create!(description: @service_income[:description],
                                      amount: calculate_amount(@service_income[:amount]))
    if sales_invoice
      income.create_invoice!(income: income,
                             number: sales_invoice.number,
                             date: sales_invoice.issue_date,
                             percentage: @invoice_percentage)
      up_parameter(:invoice, income.invoice)
      up_parameter(:sales_invoice, sales_invoice)
    end

    return {incomes: @balance.incomes,
            total: @balance.total_incomes}

  rescue StandardError => error
    errors.add(:messages, "error adding incomes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  # El frontend manda el número de factura (ej. FEKL10758) en invoiceId.
  def find_sales_invoice
    number = @service_income['invoiceId'].to_s
    sales_invoice = SalesInvoice.find_by(number: number)
    raise StandardError, "la factura #{number} no está cargada desde el Drive" unless sales_invoice
    raise StandardError, "la factura #{number} está anulada (#{sales_invoice.annulled_by})" if sales_invoice.annulled?

    used = Invoice.where(number: number).sum(:percentage).to_f
    if used + @invoice_percentage.to_f > 100.0001
      raise StandardError, "la factura #{number} ya está usada al #{used.round(2)}%"
    end

    sales_invoice
  end

  def calculate_amount(amount)
    ((amount * @invoice_percentage.to_f)/100).round 2
  end
end
