class AddNulleableToClearingColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :clearings, :balance_id, :int, null: true
  end
end
