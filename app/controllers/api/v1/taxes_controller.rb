module Api
  module V1
    class TaxesController < ApiController

      def resume_taxes
        execute_command(DetailTaxes.new())
      end
    end
  end
end