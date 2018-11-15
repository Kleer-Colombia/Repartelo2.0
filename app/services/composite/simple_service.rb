class SimpleService
  prepend Service

  def initialize
  end

  def call
    puts 1.0
    errors.add(:messages, "Error looking the coaching sessions")
  end
end