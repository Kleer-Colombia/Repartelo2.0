module Api
  module V1
    class ReportsController < ApiController

      respond_to :csv
      before_action :set_actions

      def set_actions
        @actions ||= DataLoadActions.new
      end

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

      def expenses_load
        validate_parameters [:saldos_pack], params do
          begin
            response = @actions.load_expenses(params[:saldos_pack])
            send_response response
          rescue StandardError => error
            halt_message("can't add saldos: #{error.message}", :internal_server_error)
          end
        end
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
