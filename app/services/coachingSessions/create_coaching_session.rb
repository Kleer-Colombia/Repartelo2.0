class CreateCoachingSession
  prepend Service

  attr_reader :coaching_session
  attr_accessor :balance_id, :data

  def initialize(balance_id, data)
    @balance_id = balance_id
    @data = data
  end

  def call
    instance_coaching_session(@data)
    add_kleerers(@data[:kleerers])
    @coaching_session.balance_id = @balance_id
    @coaching_session.save!
    return true
  rescue StandardError => error
    puts error
    errors.add(:messages, "Invalid parameters creating coaching session #{error}")
  end

  #TODO onlye one public method .... rspec
  def instance_coaching_session(data)
    @coaching_session = CoachingSession.new(
        complementary: data[:complementary],
        description: data[:description],
        date: Date.strptime(data[:date], '%Y-%m-%d')
    )
  end

  def add_kleerers(kleerers)
    kleerers.each do |kleerer_id|
      @coaching_session.kleerers << Kleerer.find(kleerer_id)
    end
  end



end