module Api
  module V1
    class SaldosController < ApplicationController

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
              halt_message 500,error.message
            end
        end
      end

      def add_saldo
          validate_parameters [:saldo], params do
            begin
              response = @actions.add_saldo saldo: params[:saldo]
              send_response response
            rescue StandardError => error
              halt_message 500,error.message
            end
        end
      end
    end
  end
end