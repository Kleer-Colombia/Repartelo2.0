module Api
  module V1
    class CoachingSessionsController < ApiController
      # summary es POST pero, con updatePercentage=false, solo lee: el front lo
      # llama al abrir un balance de coaching. Solo exige admin si actualiza.
      skip_before_action :require_admin_for_writes, only: :summary

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
        authorize!(:write) if ActiveModel::Type::Boolean.new.cast(params[:updatePercentage])
        validate_parameters [:id, :updatePercentage], params do
          execute_command(SummaryAndUpdateCoachingSession.new(
                            params[:id], params[:updatePercentage]))
        end
      end
    end
  end
end


