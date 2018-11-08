module Api
  module V1
    class CoachingSessionsController < ApiController

      def create
        validate_parameters [:balanceId, :coaching_session], params do
          execute_command(CreateCoachingSession.new(
              params[:balanceId], params[:coaching_session]))
        end
      end

      def find
        validate_parameters [:id], params do
          execute_command(FindCoachingSession.new(params[:id]))
        end
      end

      def delete
        validate_parameters [:id, :csId], params do
          execute_command(DeleteCoachingSession.new(params[:csId]))
        end
      end

      def summary
        validate_parameters [:id, :updatePercentage], params do
          execute_command(SummaryCoachingSession.new(
              params[:id],params[:updatePercentage]))
        end
      end
    end
  end
end


