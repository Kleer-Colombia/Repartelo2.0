class AddIncome
  prepend Service
  attr_accessor :balance_id, :income, :invoice_date, :iva, :invoice_id

  def initialize(data)
    @balance_id = data[:balance_id]
    @income = data[:income]
    @invoice_date = Time.now
    @iva = 0
    @invoice_id = ''
  end

  def call
    balance = Balance.find(@balance_id)
    get_data_from_invoice if @income['invoiceId']

    balance.incomes.create!(description: @income[:description],
                            amount: @income[:amount],
                            invoice_date: @invoice_date,
                            iva: @iva,
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
      @invoice_date = invoice['date']
      @invoice_id = invoice['id']
      @iva = find_iva_percentage(invoice['items'])

  end

  def find_iva_percentage(items)
    iva = 0
    items.each do |item|
      taxes = item['tax']
      taxes.each do |tax|
        percentage = tax['percentage'].to_f
        iva = percentage if percentage > iva
      end
    end
    iva
  end

end