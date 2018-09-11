module Api
  module V1
    class CoachingSessionsController < ApiController

      def create
        validate_parameters [:balanceId, :coaching_session], params do
          create = CreateCoachingSession.new
          create.add_subscriber(self)
          create.call params[:balanceId], params[:coaching_session]
        end
      end

    end
  end
end


