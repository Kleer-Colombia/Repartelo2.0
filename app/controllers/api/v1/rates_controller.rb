module Api
  module V1
    class RatesController < ApiController

      before_action :set_actions

      def set_actions
        @rate_actions ||= RatesActions.new
      end

      def add_trm
        validate_parameters [:trm], params do
          begin
            trm = params[:trm]
            response = @rate_actions.add_trm(trm)
            send_response response
          rescue StandardError => error
            halt_message("can't add new rate: #{error.message}", :internal_server_error)
          end
        end
      end
    end
  end
end

