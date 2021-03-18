class DistributeBalance
  prepend Service
  attr_accessor :balance_id

  def initialize(data)
    @balance_id = data[:balance_id]
  end

  def call
    balance = Balance.find(@balance_id)
    raise StandardError.new("the balance must have taxes") if balance.taxes.empty?
    raise StandardError.new("How to distribute?") if balance.percentages.empty?

    result = distribute(balance)
    data = balance.prepare_distributions(result)
    data
  rescue StandardError => error
    errors.add(:messages, "error on distribution balance: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end


  private

  def distribute(balance)

      profit = balance.calculate_profit
      distributions = balance.distribute(profit)
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



end