module Api
  module V1
    class ObjectivesController < ApiController

      before_action :set_actions

      def set_actions
        @saldo_actions ||= SaldosActions.new
        @objectives_actions ||= ObjetivesActions.new
      end

      def find_kleerco_reports
        # begin
          kleerCo = Kleerer.find_by(name: "KleerCo")
          kleerCo_id = kleerCo.id

          response = {
            total: @saldo_actions.find_saldos_of_balances(kleerCo_id),
            kleerers: @objectives_actions.find_kleerers_inputs(kleerCo),
            objectives: @objectives_actions.find_objectives(kleerCo_id)
          }
          send_response response
        # rescue StandardError => error
        #   halt_message("can't find kleerCo report: #{error.message}", :internal_server_error)
        # end
      end

      def add_objective_kleerco
        validate_parameters [:objective], params do
          begin
            kleerCo = Kleerer.find_by(name: "KleerCo")

            response = @objectives_actions.add_objective(params[:objective], kleerCo.id)
            send_response response
          rescue StandardError => error
            halt_message("can't add objective: #{error.message}", :internal_server_error)
          end
        end
      end
    end
    end
end
