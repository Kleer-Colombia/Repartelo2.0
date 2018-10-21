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

      def find
        validate_parameters [:id], params do
          find = FindCoachingSession.new
          find.add_subscriber(self)
          find.call params[:id]
        end
      end

      def delete
        validate_parameters [:id, :csId], params do
          delete = DeleteCoachingSession.new
          delete.add_subscriber(self)
          delete.call params[:csId]
        end
      end

      def summary
        puts params
        validate_parameters [:id, :updatePercentage], params do
          summary = SummaryCoachingSession.new
          summary.add_subscriber(self)
          summary.call(params[:id],params[:updatePercentage])
        end
      end
    end
  end
end


