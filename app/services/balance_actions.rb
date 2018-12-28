class BalanceActions

  def initialize
    @accounter = Accounter.new
    @saldos =  SaldosActions.new
  end

  def close balanceId
    balance = Balance.find(balanceId)
    distributions = balance.distributions
    distributions.each do |distribution|
      @saldos.add_saldo distribution: distribution,balance: balance
    end
    balance.editable = false
    balance.save!
  end

 def add_income_to_balance id,income
    balance = Balance.find(id)
    balance.incomes.create!(description: income[:description],amount: income[:amount])
    return {incomes: balance.incomes,
            total: @accounter.calculate_total_incomes(balance)}
  end

  def remove_income_to_balance(id,idIncome)
    balance = Balance.find(id)
    balance.incomes.find(idIncome).destroy
    return {incomes: balance.incomes,
            total: @accounter.calculate_total_incomes(balance)}
  end

  def add_expense_to_balance id,expense
    balance = Balance.find(id)
    balance.expenses.create!(description: expense[:description],amount: expense[:amount])
    return {expenses: balance.expenses,
            total: @accounter.calculate_total_expenses(balance)}
  end

  def remove_expense_to_balance(id,idExpense)
    balance = Balance.find(id)
    balance.expenses.find(idExpense).destroy
    return {expenses: balance.expenses,
            total: @accounter.calculate_total_expenses(balance)}
  end

  def find_complete_balance(id)
    balance = Balance.find(id)
    return {balance: balance,
            incomes: {incomes: balance.incomes,
                      total: @accounter.calculate_total_incomes(balance)},
            expenses: {expenses: balance.expenses,
                      total: @accounter.calculate_total_expenses(balance)},
            distributions: prepare_distributions(balance.distributions),
            percentages: balance.percentages,
            resume: balance.resume
            }
  end

  #TODO refactor, this method was duplicated on distribute_balance
  def prepare_distributions distributions
    data = []
    distributions.each do |distribution|
      data.push({kleerer: distribution.kleerer.name,
                 amount: distribution.amount})
    end
    return data
  end

  def update_kleerers_percentages(id, kleerers)
    balance = Balance.find(id)
    balance.percentages.clear
    kleerers.each do |kleerer|
      balance.percentages.push(Percentage.new(value: kleerer[:value], kleerer_id: kleerer[:id]))
    end
    @accounter.clean_distributions balance
    balance.save!

  end

  def delete_balance(balance_id)
    ActiveRecord::Base.transaction do
      Percentage.where(balance_id: balance_id).destroy_all
      Income.where(balance_id: balance_id).destroy_all
      Expense.where(balance_id: balance_id).destroy_all
      Distribution.where(balance_id: balance_id).destroy_all
      Tax.where(balance_id: balance_id).destroy_all
      Balance.where(id: balance_id).destroy_all
    end
  end

end