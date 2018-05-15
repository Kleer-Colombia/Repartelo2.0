module Api
  module V1
    class BalanceController < ApplicationController

      before_action :set_actions

      def set_actions
        @accounter ||= Accounter.new
        @actions ||= BalanceActions.new
      end

      def distribute
        validate_parameters [:balanceId], params do
          begin
            balance = @actions.distribute params[:balanceId]
            send_response balance
          rescue StandardError => error
            halt_message 500,error.message
          end
        end
      end

      def close
        validate_parameters [:balanceId],params do
          begin
            @actions.close params[:balanceId]
            send_response "Ok"
          rescue StandardError => error
            halt_message 500,error.message
          end
        end
      end

      def find_all
        send_response Balance.all
      end

      def create
        validate_parameters [:balance], params do
          balance = params[:balance]
          begin
            result = Balance.create!(
                project: balance['project'],
                client: balance['client'],
                description: balance['description'],
                date: Date.strptime(balance['date'],'%Y-%m-%d'))
            send_response result.id
          rescue StandardError => e
            halt_message 500,"Invalid parameters creating balance #{e}"
          end
        end

      end

      def find
        validate_parameters [:id], params do
          begin
            send_response @actions.find_complete_balance params[:id]
          rescue
            halt_message 500,'Balance not exist'
          end
        end
      end

      def delete
        validate_parameters [:id], params do
          begin
            send_response @actions.delete_balance(params[:id])
          rescue ActiveRecord::RecordInvalid => e
            halt_message 500,"We can't delete balance: #{e.message}"
          end
        end
      end

      def add_income
        validate_parameters [:id,:income], params do
          begin
            income = params[:income]
            send_response @actions.add_income_to_balance(params[:id],income)
          rescue => e
            puts e
            halt_message 500,"We can't add income"
          end
        end
      end

      def delete_income
        validate_parameters [:id,:idIncome], params do
          begin
            send_response @actions.remove_income_to_balance(params[:id],params[:idIncome])
          rescue
            halt_message 500,"We can't remove income"
          end
        end
      end

      def add_expense
        validate_parameters [:id,:expense], params do
          begin
            income = params[:expense]
            send_response @actions.add_expense_to_balance(params[:id],income)
          rescue
            halt_message 500,"We can't add expense"
          end
        end
      end

      def delete_expense
        validate_parameters [:id,:idExpense], params do
          begin
            send_response @actions.remove_expense_to_balance(params[:id],params[:idExpense])
          rescue
            halt_message 500,"We can't remove expense"
          end
        end
      end

      def update_percentages
        validate_parameters [:id,:kleerers], params do
          begin
            kleerers = params[:kleerers]
            send_response @actions.update_kleerers_percentages(params[:id],kleerers)
          rescue StandardError => e
            halt_message 500,"We can't update the kleerers distribution: #{e.message}"
          end
        end
      end
    end
  end
end