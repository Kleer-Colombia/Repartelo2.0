module Api
  module V1
    class ClearingsController < ApiController

      before_action :set_actions

      def set_actions
        @actions ||= ClearingsActions.new
      end

      def find_clearings
        validate_parameters [:country_id], params do
          begin
            puts "clearings #{params[:country_id]}"
            response = @actions.find_clearings params[:country_id]
            send_response response
          rescue StandardError => error
            halt_message("can't find clearings: #{error.message}", :internal_server_error)
          end
        end
      end

      def find_default_clearings
        begin
          default = Country.find_by(name: 'default')
          response = @actions.find_clearings default.id
          send_response response
        rescue StandardError => error
          halt_message("can't find clearings: #{error.message}", :internal_server_error)
        end
      end

      def add_clearing
        validate_parameters [:clearing], params do
          begin
            response = @actions.add_clearing(params[:clearing])
            send_response response
          rescue StandardError => error
            halt_message("can't add clearing: #{error.message}", :internal_server_error)
          end
        end
      end
    end
  end
end
