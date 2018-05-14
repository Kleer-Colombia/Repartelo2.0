class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception
  include AdminAuthorizable
  include TokenAuthenticatable


  rescue_from ActiveRecord::RecordNotFound, with: -> { render json: { error: 'Not found' }, status: :not_found }
end
