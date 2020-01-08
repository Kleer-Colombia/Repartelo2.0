class RetencionIntBalances < ActiveRecord::Migration[5.2]
  def change
    add_column :balances, :retencion, :decimal, null: true
  end
end
