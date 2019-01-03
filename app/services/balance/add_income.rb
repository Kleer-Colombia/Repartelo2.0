class AddIncome
  prepend Service
  attr_accessor :balance_id, :income

  def initialize(data)
    @balance_id = data[:balance_id]
    @income = data[:income]
  end

  def call
    balance = Balance.find(@balance_id)

    balance.incomes.create!(description: income[:description],amount: income[:amount])
    return {incomes: balance.incomes,
            total: balance.total_incomes}

  rescue StandardError => error
    errors.add(:messages, "error adding incomes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end