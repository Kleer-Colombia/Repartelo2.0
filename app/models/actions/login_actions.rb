module Login
  class IronFist
    def initialize user_repository
      @user_repository = user_repository
    end

    def validate_user email,password
      user = @user_repository.find_by_email(email)
      if user and user.authenticate(password)
        token email
      end
    end

    private

    def token email
      MyLog.log.debug "creating token for email: #{email}"
      MyLog.log.debug "with JWT_SECRET: #{ENV['JWT_SECRET']}"
      JWT.encode payload(email), ENV['JWT_SECRET'], 'HS256'
    end

    def payload(email)
      {
          exp: Time.now.to_i + 60 * 60,
          iat: Time.now.to_i,
          iss: ENV['JWT_ISSUER'],
          scopes: ['distribute','close','kleerers','new_balance','list_balance','search_balance',
                   'add_income','remove_income','add_expense','remove_expense','update_percentages',
                  'delete_balance','saldos','add_saldo'],
          user: {
            email: email
          }
      }
    end
  end
end
