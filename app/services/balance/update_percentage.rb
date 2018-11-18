# frozen_string_literal: true
class UpdatePercentage
  prepend Service
  attr_accessor :summary, :balance_id, :kleerers

  def initialize(balance_id, data)
    @balance_id = balance_id
    @kleerers = data[:kleerers]
    @summary = data[:summary]
  end

  def call
    if @kleerers
      update_kleerers_percentages(@balance_id, @kleerers)
    else
      update_percentage_for_coaching_balance(@balance_id, @summary)
    end

    return true
  rescue StandardError => error
    errors.add(:messages, "We can't update the kleerers distribution: #{error.message} ")
  end

  private

  def update_percentage_for_coaching_balance(balance_id, summary)
    kleerers = []
    summary[:distribution].each do |distribution|
      kleerer = { value: distribution[:percentage], id: distribution[:kleerer_id] }
      kleerers << kleerer
    end
    update_kleerers_percentages(balance_id, kleerers)
  end

  def update_kleerers_percentages(balance_id, kleerers)
    balance = Balance.find(balance_id)
    balance.percentages.clear
    kleerers.each do |kleerer|
      balance.percentages.push(Percentage.new(value: kleerer[:value], kleerer_id: kleerer[:id]))
    end
    #TODO actions for distributions on accounter:56
    balance.distributions.clear
    balance.save!

  end
end
