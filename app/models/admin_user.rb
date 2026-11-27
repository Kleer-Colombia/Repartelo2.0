class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :lockable bloquea la cuenta tras varios intentos fallidos (se desbloquea
  # sola pasado un rato; ver config/initializers/devise.rb).
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable
end
