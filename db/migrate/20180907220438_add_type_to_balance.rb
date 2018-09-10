class AddTypeToBalance < ActiveRecord::Migration[5.1]
  def change
    add_column :balances, :balance_type, :string, default: 'standard', null: false
  end
end
