class ApiController < ActionController::API

  include AdminAuthorizable
  include TokenAuthenticatable

  rescue_from ActiveRecord::RecordNotFound, with: -> { render json: { error: 'Not found' }, status: :not_found }

  def validate_parameters(parameters, array)
    for parameter in parameters
      param = array[parameter]
      if(!validate(param))
        halt_message "Invalid parameters: #{parameter}" , :internal_server_error and return
      end
    end
    yield
  end

  def halt_message  message, error_code = :internal_server_error
    render json: { message: message }, status: error_code
  end

  def send_response object, status = :ok
    render json: { response: object }, status: status
  end

  def execute_command(command)
    command = command.call
    if command.success?
      send_response(command.result)
    else
      command.errors[:error_code] ||= :internal_server_error
      halt_message(command.errors[:messages], command.errors[:error_code])
    end
  end

  private

  #TODO inspeccionar los hash y los arrays y hacerlos recursivos?
  def validate(parameter)
   if(!parameter.nil?)
      return ((parameter.is_a?(Hash) and !parameter.empty?) or
          (parameter.is_a?(Array) and !parameter.empty?) or
          !parameter.to_s.empty?)
    end
  end
end