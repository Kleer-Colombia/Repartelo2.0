module Api
  module V1
    class ReportsController < ApiController

      respond_to :csv

      def financial_report
        command = FinancialReport.new()
        call(command,"financialReport-#{Date.today}.csv")
      end

      def expenses_report
        command = ExpensesReport.new()
        call(command,"expensesReport-#{Date.today}.csv")
      end

      def saldos_report
        command = SaldosReport.new()
        call(command,"saldosReport-#{Date.today}.csv")
      end

      private

      def call(command, name)
        command = command.call
        if command.success?
          send_data command.result, filename: name
        else
          command.errors[:error_code] ||= :internal_server_error
          render json: {message: command.errors[:messages]}, status: command.errors[:error_code][0]
        end
      end

    end
  end
end
