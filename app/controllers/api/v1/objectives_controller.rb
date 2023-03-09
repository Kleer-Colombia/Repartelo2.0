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
              all_kleerers: Kleerer.all,
              distributed_objectives: @objectives_actions.find_objectives_distributions,
              total: @saldo_actions.find_saldos_of_balances(kleerCo_id),
              kleerers: @objectives_actions.find_kleerers_inputs(kleerCo),
              objectives: @objectives_actions.find_objectives,
              filtered_kleerers: @objectives_actions.find_filtered_kleerers(0,  @objectives_actions.find_kleerers_inputs(kleerCo), @objectives_actions.find_objectives)

          }
          send_response response
        # rescue StandardError => error
        #   halt_message("can't find kleerCo report: #{error.message}", :internal_server_error)
        # end
      end

      def add_objective_kleerco
        validate_parameters [:objective], params do
          begin
            response = @objectives_actions.add_objective(params[:objective])
            send_response response
          rescue StandardError => error
            halt_message("can't add objective: #{error.message}", :internal_server_error)
          end
        end
      end

      def add_kleerer_to_objective
        validate_parameters [:objective_id, :kleerer_id], params do
          begin
            @objectives_actions.add_kleerer_to_objective(params[:objective_id], params[:kleerer_id])
          rescue
            halt_message("can't add kleerer: #{error.message}", :internal_server_error)
          end
        end
      end
    end
    end
end
