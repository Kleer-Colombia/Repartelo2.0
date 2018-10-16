class FindCoachingSession < Publisher

  def call(balance_id)

    coaching_sessions = CoachingSession.where(balance_id: balance_id)

    publish(:send_response, prepare_data(coaching_sessions))
  rescue StandardError => error
    publish(:halt_message,
            "Error looking the coaching sessions")
  end

  private

  def prepare_data(coaching_sessions)
    data = []
    coaching_sessions.each do|cs|
      registry = {}
      registry[:id] = cs.id
      registry[:date] = cs.date
      registry[:description] = cs.description
      registry[:complementary] = cs.complementary
      registry[:kleerers] = []
      cs.kleerers.each do |kleerer|
        registry[:kleerers].push(kleerer.name)
      end
      data.push(registry)
    end

    return data
  end
end