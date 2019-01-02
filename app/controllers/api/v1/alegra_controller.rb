module Api
  module V1
    class AlegraController < ApiController
      def find_open_invoices
          execute_command(FindInvoices.new(status: :open))
      end
    end
  end
end