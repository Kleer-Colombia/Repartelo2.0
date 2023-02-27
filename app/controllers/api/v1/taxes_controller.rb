module Api
  module V1
    class TaxesController < ApiController

      def resume_taxes
        execute_command(DetailTaxes.new())
      end

      #disable
      def resume_one_tax
        execute_command(DetailOneTax.new(params[:taxId],params[:tax_year]))
      end

      def add_tax
        execute_command(AddManualTax.new(params[:taxInfo]))
      end
    end
  end
end
