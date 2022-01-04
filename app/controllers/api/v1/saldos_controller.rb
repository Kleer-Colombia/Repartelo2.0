module Api
  module V1
    class SaldosController < ApiController

      before_action :set_actions

      def set_actions
        @actions ||= SaldosActions.new
      end

      def find_saldos
          validate_parameters [:kleerer_id], params do
            begin
              response = @actions.find_saldos params[:kleerer_id]
              send_response response
            rescue StandardError => error
              halt_message("can't find saldos: #{error.message}", :internal_server_error)
            end
        end
      end

      def add_saldo
          puts params
          validate_parameters [:saldo], params do

            begin
              response = @actions.add_saldo saldo: params[:saldo]
              send_response response
            rescue StandardError => error
              halt_message("can't add saldo: #{error.message}", :internal_server_error)
            end
        end
      end


    end
  end
end
