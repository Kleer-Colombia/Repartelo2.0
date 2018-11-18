class FindCoachingSession
  prepend Service

  attr_accessor :balance_id

  def initialize(balance_id)
    @balance_id = balance_id
  end

  def call
    coaching_sessions = CoachingSession.where(balance_id: @balance_id).order(:date)
    return prepare_data(coaching_sessions)
  rescue StandardError => error
    errors.add(:messages, "Error looking the coaching sessions")
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