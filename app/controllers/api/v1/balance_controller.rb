module Api
  module V1
    class BalanceController < ApiController

      before_action :set_actions

      def set_actions
        @actions ||= BalanceActions.new
      end

      def find_all
        send_response(Balance.all, :ok)
      end

      def create
        validate_parameters [:balance], params do
          balance = params[:balance]
          begin
            result = Balance.create!(
              project: balance['project'],
              client: balance['client'],
              description: balance['description'],
              balance_type: balance['balance_type'],
              date: Date.strptime(balance['date'], '%Y-%m-%d'))
            send_response result.id
          rescue StandardError => e
            halt_message("Invalid parameters creating balance #{e}", :internal_server_error)
          end
        end

      end

      def find
        validate_parameters [:id], params do
          begin
            send_response @actions.find_complete_balance params[:id]
          rescue
            halt_message("Balance not exist", :no_content)
          end
        end
      end

      def delete
        validate_parameters [:id], params do
          begin
            send_response @actions.delete_balance(params[:id])
          rescue ActiveRecord::RecordInvalid => e
            halt_message("We can't delete balance: #{e.message}", :internal_server_error)
          end
        end
      end

    end
  end
end