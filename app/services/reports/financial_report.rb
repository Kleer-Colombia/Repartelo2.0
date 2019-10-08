class FinancialReport
  prepend Service

  def initialize()

  end

  def call
    Balance.all.each do |balance|
      data = extract_data(balance)
      consolidate_line(data)
    end

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error saving manual tax: #{error.message}")
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
    puts "#{data[:balance_id]},#{data[:invoices]},#{data[:expenses]},#{data[:chanchito]},#{data[:distribucion]}"
  end

end