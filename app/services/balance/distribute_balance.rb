class DistributeBalance
  prepend Service
  attr_accessor :balance_id, :kleerCo

  def initialize(data)
    @balance_id = data[:balance_id]
    @kleerCo = Kleerer.find_by(name: "KleerCo")
  end

  def call
    balance = Balance.find(@balance_id)
    raise StandardError.new("the balance must have taxes") if balance.taxes.empty?
    raise StandardError.new("How to distribute?") if balance.percentages.empty?

    result = distribute(balance)
    prepare_distributions(result)
  rescue StandardError => error
    errors.add(:messages, "error on distribution balance: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end


  private

  def distribute(balance)

      profit = balance.calculate_profit
      forKleerCo = balance.find_tax_value(:kleerCo)

      distributions = {@kleerCo.id => forKleerCo}

      balance.percentages.each do |percentage|
        kleerer = percentage.kleerer
        forKleerer = (profit * percentage.value) / 100
        re_entry = forKleerer * kleerer.option.value * 0.01

        distributions[@kleerCo.id] += re_entry
        distributions[kleerer.id] = forKleerer - re_entry
      end

      save_distributions(balance, distributions)
      balance.distributions

  end

  def clean_distributions balance
    balance.distributions.clear
  end

  def save_distributions balance, distributions
    clean_distributions(balance)
    distributions.each do |id, amount|
      balance.distributions.push(Distribution.new(amount: amount.round(2), kleerer_id: id))
    end
    balance.save!
  end

  def prepare_distributions distributions
    data = []
    distributions.each do |distribution|
      data.push({kleerer: Kleerer.find(distribution.kleerer_id).name,
                 amount: distribution.amount})
    end
    return data
  end


end