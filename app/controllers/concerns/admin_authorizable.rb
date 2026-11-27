class NotPermittedException < StandardError; end

module AdminAuthorizable
    extend ActiveSupport::Concern
  
    included do
      rescue_from NotPermittedException, with: lambda {
        render json: { error: 'Not Permitted', message: 'Tu usuario no tiene permisos para modificar datos.' },
               status: :forbidden
      }
    end
  
    def authorize!(action)
      raise NotPermittedException if action != :read && !current_user.admin?
      true
    end
  end