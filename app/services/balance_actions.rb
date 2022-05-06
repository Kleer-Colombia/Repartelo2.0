class BalanceActions

  def initialize
    @saldos =  SaldosActions.new
  end

  def add_expense_to_balance id,expense
    balance = Balance.find(id)
    balance.expenses.create!(description: expense[:description],amount: expense[:amount])
    return {expenses: balance.expenses,
            total: balance.total_expenses}
  end

  def remove_expense_to_balance(id,idExpense)
    balance = Balance.find(id)
    balance.expenses.find(idExpense).destroy
    return {expenses: balance.expenses,
            total:balance.total_expenses}
  end

  def add_clearing_to_balance(id, clearing)
    balance = Balance.find(id)
    balance.clearings.create!(description: clearing[:description], percentage: clearing[:percentage],
                          country_id: clearing[:countryId])
    return {clearings: balance.clearings}
            # total: balance.total_clearings}
  end

  def remove_clearing_to_balance(id,idClearing)
    balance = Balance.find(id)
    puts 'id'
    puts idClearing
    balance.clearings.find(idClearing).destroy
    return {clearings: balance.clearings}
  end

  def find_all_balances()
    balances = Balance.all
    hashed_balances = []
    balances.each do |balance|
      balance_to_hash = balance.attributes
      balance_to_hash[:incomes] = balance.incomes
      hashed_balances.push(balance_to_hash)

    end
    hashed_balances
  end

  def find_complete_balance(id)
    balance = Balance.find(id)
    countries = Country.all
    puts "facturas asociadas"
    balance.incomes.each do |income|
      puts income.description
    end
    balance_info = {balance: balance,
                    incomes: {incomes: balance.incomes,
                              total: balance.total_incomes},
                    expenses: {expenses: balance.expenses,
                              total: balance.total_expenses},
                    clearings: balance.clearings,
                    distributions: balance.prepare_distributions(balance.distributions),
                    percentages: balance.percentages,
                    resume: balance.resume,
                    disponible_countries: countries
            }
    balance_info
  end

  def find_expenses_balance(id)
    balance = Balance.find(id)
    return { expenses: balance.expenses,
             total: balance.total_expenses
    }
  end

  def find_clearings_balance(id)
    balance = Balance.find(id)
    return balance.clearings
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

  def edit_properties_balance(properties)
    balance = Balance.find(properties['id'])
    balance.client = properties['client']
    balance.project = properties['project']
    balance.description = properties['description']
    balance.date = Date.strptime(properties['date'], '%Y-%m-%d')
    balance.save!
  end

end
