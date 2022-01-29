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
          #TODO: hay que mirar como encontrar el iva

          execute_command(CalculateTaxes.new(taxes: TaxMaster.all_taxes(balance),
                                             incomes: balance.total_incomes,
                                             expenses: balance.total_expenses,
                                             save_in: balance))
        end
      end

      def close
        validate_parameters [:balanceId], params do
          execute_command(CloseBalance.new(params[:balanceId]))
        end
      end

      def add_income
        validate_parameters [:id, :income], params do
          execute_command(AddIncome.new(params[:id], params[:income]))
        end
      end

      def delete_income
        validate_parameters [:id, :idIncome], params do
          execute_command(DeleteIncome.new(params[:id], params[:idIncome]))
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

      def find_expenses
        validate_parameters [:id], params do
          begin
            send_response @actions.find_expenses_balance(params[:id])
          rescue
            halt_message("We can't find expenses: #{e.message}", :internal_server_error)
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
