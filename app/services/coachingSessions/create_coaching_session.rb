class CreateCoachingSession < Publisher

  attr_reader :coaching_session

  def call(balance_id, data)
    instance_coaching_session data
    add_kleerers data[:kleerers]
    @coaching_session.balance_id = balance_id
    @coaching_session.save!

    publish(:send_response, true)
  rescue StandardError => error
    publish(:halt_message,
            "Invalid parameters creating coaching session #{error}")
  end

  def add_kleerers(kleerers)
    kleerers.each do |kleerer_id|
      @coaching_session.kleerers << Kleerer.find(kleerer_id)
    end
  end

  def instance_coaching_session(data)
    @coaching_session = CoachingSession.new(
        complementary: data[:complementary],
        description: data[:description],
        date: Date.strptime(data[:date], '%Y-%m-%d')
    )
  end

end