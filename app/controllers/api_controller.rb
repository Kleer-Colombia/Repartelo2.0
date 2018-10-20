class ApiController < ActionController::API

  include AdminAuthorizable
  include TokenAuthenticatable

  rescue_from ActiveRecord::RecordNotFound, with: -> { render json: { error: 'Not found' }, status: :not_found }

  #TODO what happen when the parameter is and object?
  # TODO REFACTOR this please
  def validate parameter
    parameter and !parameter.to_s.empty?
  end

  def validate_parameters parameters, array
    for parameter in parameters
      param = array[parameter]
      if !validate(param)
        halt_message :unauthorized,"Invalid parameters: #{parameter}" and return
      end
    end
    yield
  end

  #TODO validar codigos de errores
  def halt_message  message, error_code = 400
    render json: { message: message }, status: error_code
  end

  def send_response object, status = 200
    render json: { response: object }, status: status
  end

  class PersistenceResponse < SimpleDelegator
    def halt_message(message, error_code = 500)
      render json: { message: message }, status: error_code
    end

    def send_response(object, status = 200)
      render json: { response: object }, status: status
    end
  end

end