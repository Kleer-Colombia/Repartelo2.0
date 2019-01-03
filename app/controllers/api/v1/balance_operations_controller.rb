module Api
  module V1
    class BalanceOperationsController < ApiController

      before_action :set_actions

      def set_actions
        @actions ||= BalanceActions.new
      end

      def distribute
        validate_parameters [:balanceId], params do
          execute_command(DistributeBalance.new(balance_id: params[:balanceId]))
        end
      end

      def calculate_taxes
        validate_parameters [:balanceId], params do
          balance = Balance.find(params[:balanceId])
          execute_command(CalculateTaxes.new(taxes: TaxMaster.all,
                                             incomes: balance.total_incomes,
                                             expenses: balance.total_expenses,
                                             save_in: balance))
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

      def add_income
        validate_parameters [:id, :income], params do
          execute_command(AddIncome.new(balance_id: params[:id], income: params[:income]))
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
          execute_command(UpdatePercentage.new(params[:id], kleerers: params[:kleerers]))
        end
      end
    end
  end
end