class AddAutoIncrementToClearings < ActiveRecord::Migration[5.2]
  def change
    change_column :clearings, :id, :int, null: false, unique: true, auto_increment: true
  end
end
