module Api
  module V1
    class CountriesController < ApiController

      # before_action :set_actions
      #
      # def set_actions
      #   @saldo_actions ||= SaldosActions.new
      #   @objectives_actions ||= ObjetivesActions.new
      # end

      def find_countries
        begin
          response = Country.all
          send_response response
        rescue StandardError => error
          halt_message("can't find countries: #{error.message}", :internal_server_error)
        end
      end
    end
  end
end
