class Accounter

 attr_accessor :option_kleer_co, :option_kleerer

  OPTIONS = {socio: 0.05,full:0.15,parcial: 0.25,otro: 0.10}

  def initialize kleerCo = Kleerer.find_by(name: "KleerCo")
    @kleerCo = kleerCo
    #TODO this must be in the db
    @option_kleer_co = 0.16
    @option_kleerer = 0.84
  end

  def distribute balanceId

    balance = Balance.find(balanceId)
    if !balance.percentages.empty?
      profit = calculate_profit balance
      forKleerCo = profit*@option_kleer_co
      for_percentage_distrbution = profit*@option_kleerer

      distributions = {@kleerCo.id => forKleerCo}

      balance.percentages.each do |percentage|
        kleerer = percentage.kleerer
        forKleerer = (for_percentage_distrbution * percentage.value)/100
        re_entry = forKleerer*OPTIONS[kleerer.option.to_sym]

        distributions[@kleerCo.id] += re_entry
        distributions[kleerer.id] = forKleerer - re_entry
      end

      save_distributions(balance,distributions)
      balance.distributions
    else
      raise StandardError,'How to distribute?'
    end

  end

  def calculate_total_incomes balance
    calculate_total balance.incomes
  end

  def calculate_total_expenses balance
    calculate_total balance.expenses
  end

  def calculate_profit balance
    profit = calculate_total_incomes(balance) - calculate_total_expenses(balance)
    if profit < 0
      raise StandardError,'Nothing to distribute!'
    end
    profit
  end

  def clean_distributions balance
    balance.distributions.clear
  end

  private

  def calculate_total transactions
    total = 0
    transactions.each do |transaction|
      total += transaction.amount
    end
    total
  end

  def save_distributions balance,distributions
    clean_distributions(balance)
    distributions.each do |id,amount|
      balance.distributions.push(Distribution.new(amount: amount.round(2), kleerer_id: id))
    end
    balance.save!
  end



end