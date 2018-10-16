class DeleteCoachingSession< Publisher

  def call(csId)
    CoachingSession.destroy(csId)
    publish(:send_response, true)
  rescue StandardError => error
    publish(:halt_message,
            'Error deleting registry of coaching session')
  end

end