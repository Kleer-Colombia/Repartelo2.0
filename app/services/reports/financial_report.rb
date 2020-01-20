class FinancialReport
  prepend Service

  def initialize()

  end

  def call

    attributes = %w{id invoices expenses chanchito distribución}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      Balance.all.each do |balance|
        data = extract_data(balance)
        csv << consolidate_line(data)
      end
    end

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error generating balance: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  def extract_data(balance)
    data = {}
    data[:balance_id] = balance.id
    data[:invoices] = balance.get_incomes_names
    data[:expenses] = balance.total_expenses
    data[:chanchito] = Tax.get_tax_from('Chanchito', balance.id)
    data[:distribucion] = Distribution.get_from(balance.id)
    data
  end

  def consolidate_line(data)
    #"#{data[:balance_id]},#{data[:invoices]},#{data[:expenses]},#{data[:chanchito]},#{data[:distribucion]}"
    [data[:balance_id],data[:invoices],data[:expenses],data[:chanchito],data[:distribucion]]
  end

end