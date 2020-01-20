module Api
  module V1
    class ReportsController < ApiController

      respond_to :csv

      def financial_report
        command = FinancialReport.new()
        command = command.call
        if command.success?
          send_data command.result, filename: "financialReport-#{Date.today}.csv"
        else
          command.errors[:error_code] ||= :internal_server_error
          render json: {message: command.errors[:messages]}, status: command.errors[:error_code][0]
        end
      end

    end
  end
end
