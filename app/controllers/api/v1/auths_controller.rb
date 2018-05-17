# frozen_string_literal: true
module Api
    module V1
      class AuthsController < ApiController
        skip_before_action :authenticate_user

        def login
          validate_parameters [:username,:password], params do
            token_command = AuthenticateUserCommand.call(*params.slice(:username, :password).values)
            if token_command.success?
              render json: { token: token_command.result }
            else
              render json: { message: token_command.errors[:base][0] }, status: :unauthorized
            end
          end
        end
      end
    end
end