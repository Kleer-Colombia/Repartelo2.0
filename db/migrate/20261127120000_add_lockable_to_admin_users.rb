# Devise :lockable para ActiveAdmin: bloquea la cuenta tras varios intentos
# fallidos de login (ver config/initializers/devise.rb).
class AddLockableToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :failed_attempts, :integer, default: 0, null: false
    add_column :admin_users, :unlock_token, :string
    add_column :admin_users, :locked_at, :datetime
    add_index :admin_users, :unlock_token, unique: true
  end
end
