class AddFinalAmountToClearings < ActiveRecord::Migration[5.2]
  def change
    add_column :clearings, :final_amount, :float
  end
end
