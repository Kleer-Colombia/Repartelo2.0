class UpdatePercentage < Publisher

  def call(balance_id, kleerers)
    publish(:send_response, update_kleerers_percentages(balance_id,kleerers))
  rescue StandardError => error
    publish(:halt_message,
            "We can't update the kleerers distribution: #{e.message}")
  end


  def update_percentage_for_coaching_balance(balance_id, summary)
    kleerers = []
    summary[:distribution].each do |distribution|
      kleerer = { value: distribution[:percentaje],kleerer_id: distribution[:kleerer_id] }
      kleerers << kleerer
    end

    update_kleerers_percentages(balance_id,kleerers)
  end

  private

  def update_kleerers_percentages(balance_id, kleerers)
    balance = Balance.find(balance_id)
    balance.percentages.clear
    kleerers.each do |kleerer|
      balance.percentages.push(Percentage.new(value: kleerer[:value], kleerer_id: kleerer[:id]))
    end
    @accounter.clean_distributions balance
    balance.save!

  end

end