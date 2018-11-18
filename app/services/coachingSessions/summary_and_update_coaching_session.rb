class SummaryAndUpdateCoachingSession
  prepend ComposedService

  def initialize(balance_id, update_percentage)
    super
    add_service(SummaryCoachingSession.new(balance_id))
    add_service(UpdatePercentage.new(balance_id, summary: Service::INSPECT)) if update_percentage
  end

end