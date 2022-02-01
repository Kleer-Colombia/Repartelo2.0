class AddInitialBalanceToObjectives < ActiveRecord::Migration[5.2]
  def change
    add_column :objectives, :initial_balance_percentage, :float
  end
end
