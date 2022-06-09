module Api
  module V1
    class RatesController < ApiController

      def add_trm
        validate_parameters [:trm], params do
          begin
            trm = params[:trm]
            response = RepresentativeMarketRate.new(rate: trm[:rate], date: trm[:date], currency: trm[:currency])
            response.save!
            send_response response
          rescue StandardError => error
            halt_message("can't add new rate: #{error.message}", :internal_server_error)
          end
        end
      end
    end
  end
end

