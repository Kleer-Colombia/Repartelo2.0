module Api
  module V1
    class BalanceController < ApiController

      before_action :set_actions

      def set_actions
        @accounter ||= Accounter.new
        @actions ||= BalanceActions.new
      end

      def distribute
        validate_parameters [:balanceId], params do
          distribute = DistributeBalance.new
          distribute.add_subscriber(self)
          distribute.call params[:balanceId]
        end
      end

      def close
        validate_parameters [:balanceId], params do
          begin
            @actions.close params[:balanceId]
            send_response('Ok')
          rescue StandardError => error
            halt_message("can't close balance: #{error.message}", :internal_server_error)
          end
        end
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

      def add_income
        validate_parameters [:id, :income], params do
          begin
            income = params[:income]
            send_response @actions.add_income_to_balance(params[:id], income)
          rescue => e
            halt_message("We can't add income #{e.message}", :internal_server_error)
          end
        end
      end

      def delete_income
        validate_parameters [:id, :idIncome], params do
          begin
            send_response @actions.remove_income_to_balance(params[:id], params[:idIncome])
          rescue
            halt_message("We can't remove income: #{e.message}", :internal_server_error)
          end
        end
      end

      def add_expense
        validate_parameters [:id, :expense], params do
          begin
            income = params[:expense]
            send_response @actions.add_expense_to_balance(params[:id], income)
          rescue
            halt_message("We can't add expense: #{e.message}", :internal_server_error)
          end
        end
      end

      def delete_expense
        validate_parameters [:id, :idExpense], params do
          begin
            send_response @actions.remove_expense_to_balance(params[:id], params[:idExpense])
          rescue
            halt_message("We can't remove expense: #{e.message}", :internal_server_error)
          end
        end
      end

      def update_percentages
        validate_parameters [:id, :kleerers], params do
          update_percentages = UpdatePercentage.new
          update_percentages.add_subscriber(self)
          update_percentages.call(params[:id], params[:kleerers])
        end
      end
    end
  end
end