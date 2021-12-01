module Api
  module V1
    class ObjectivesController < ApiController

      before_action :set_actions

      def set_actions
        @actions ||= SaldosActions.new
      end

      def find_kleerco_reports
        begin
          kleerCo = Kleerer.find_by(name: "KleerCo")
          kleerCo_id = kleerCo.id
          response = @actions.find_saldos_of_balances kleerCo_id
          send_response response
        rescue StandardError => error
          halt_message("can't find kleerCo report: #{error.message}", :internal_server_error)
        end
      end
    end
  end
end
