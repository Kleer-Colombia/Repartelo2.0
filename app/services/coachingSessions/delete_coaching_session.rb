class DeleteCoachingSession
  prepend SimpleCommand

  def initialize (cs_id)
    @cs_id = cs_id
  end

  def call
    CoachingSession.destroy(@cs_id)
    return true
  rescue StandardError => error
    errors.add(:messages, 'Error deleting registry of coaching session')
  end

end