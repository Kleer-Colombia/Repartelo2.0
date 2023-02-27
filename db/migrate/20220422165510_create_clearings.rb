class CreateClearings < ActiveRecord::Migration[5.2]
  def change
    create_table :clearings do |t|
      t.belongs_to :balance, index: true, :null => false
      t.belongs_to :country, index: true, :null => false
      t.decimal :percentage
      t.decimal :amount
      t.string :description
      t.timestamps
    end
  end
end
