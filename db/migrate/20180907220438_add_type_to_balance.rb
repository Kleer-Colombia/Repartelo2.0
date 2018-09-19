class AddTypeToBalance < ActiveRecord::Migration::Current
  def change
    add_column :balances, :balance_type, :string, default: 'standard', null: false
  end
end
