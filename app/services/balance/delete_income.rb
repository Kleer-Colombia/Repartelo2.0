class DeleteIncome
  prepend Service

  attr_accessor :balance, :income_id

  def initialize(balance_id, income_id)
    @balance = Balance.find(balance_id)
    @income_id = income_id
  end

  #TODO al borrar y agregar mas de una factura, falla

  def call

    income = @balance.incomes.find(@income_id)

    if income.invoice_id
      @balance.taxes -= @balance.find_in_invoice_taxes
      @balance.save!
    end

    income.destroy
    { incomes: balance.incomes,
      total: balance.total_incomes }
  rescue StandardError => e
    errors.add(:messages, "We can't remove income: #{e.message}")
    errors.add(:error_code, :not_acceptable)
  end
end
