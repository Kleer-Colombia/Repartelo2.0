class AddOwnerToBalances < ActiveRecord::Migration[5.2]
  def change
    add_column :balances, :kleerer_id, :integer
  end
end
