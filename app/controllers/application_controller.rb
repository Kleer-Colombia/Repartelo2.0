class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include AdminAuthorizable
  include TokenAuthenticatable

  rescue_from ActiveRecord::RecordNotFound, with: -> { render json: { error: 'Not found' }, status: :not_found }

  #TODO what happen when the parameter is and object?
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

  def halt_message error_code, message
    render json: { message: message }, status: error_code
  end

  def send_response object, status = 200
    render json: { response: object }, status: status
  end
end
