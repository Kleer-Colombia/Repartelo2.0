class DeleteIncome
  prepend Service

  attr_accessor :balance, :income_id

  def initialize(balance_id, income_id)
    @balance = Balance.find(balance_id)
    @income_id = income_id
  end

  def call
    income = @balance.incomes.find(@income_id)
    if income.invoice_id
      delete_taxes_only_for_invoice(income)
    end
    income.destroy

    { incomes: balance.incomes,
      total: balance.total_incomes }
  rescue StandardError => e
    errors.add(:messages, "We can't remove income: #{e.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def delete_taxes_only_for_invoice(income)
    taxes_to_delete = @balance.find_in_invoice_taxes.select do |tax|
      tax.invoice_id == income.invoice_id
    end
    @balance.taxes -= taxes_to_delete
    @balance.save!
  end
end
