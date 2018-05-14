class AuthenticateUserCommand < BaseCommand
    private
  
    attr_reader :email, :password
  
    def initialize(email, password)
      @email = email
      @password = password
    end
  
    def user
      @user ||= User.find_by(email: email)
    end
  
    def password_valid?
      user && user.authenticate(password)
    end
  
    def payload
      if password_valid?
        @result = JwtService.encode(contents)
      else
        errors.add(:base, I18n.t('authenticate_user_command.invalid_credentials'))
      end
    end
  
    def contents
      {
        user_id: user.id,
        exp: 1.hours.from_now.to_i,
        iat: Time.now.to_i,
        scopes: ['distribute','close','kleerers','new_balance','list_balance','search_balance',
                 'add_income','remove_income','add_expense','remove_expense','update_percentages',
                 'delete_balance','saldos','add_saldo'],
        user: {
            email: email
        }
      }

    end
  end