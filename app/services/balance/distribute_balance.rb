class DistributeBalance < Publisher

  def initialize
    @accounter = Accounter.new
  end

  def call(balance_id)
    distributions = distribute(balance_id)
    publish(:send_response, distributions)
  rescue StandardError => error
    publish(:halt_message,
            "error on distribution balance: #{error.message}", :not_acceptable)
  end

  def distribute balanceId
    distributions = @accounter.distribute balanceId
    return prepare_distributions distributions
  end

  private

  def prepare_distributions distributions
    data = []
    distributions.each do |distribution|
      data.push({kleerer: distribution.kleerer.name,
                 amount: distribution.amount})
    end
    return data
  end


end