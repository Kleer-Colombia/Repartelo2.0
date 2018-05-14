class CreatePercentages < ActiveRecord::Migration[5.1]
  def change
    create_table :percentages do |t|
      t.belongs_to :balance, index: true, :null => false
      t.belongs_to :kleerer, index: true, :null => false
      t.decimal :value, :null => false
      t.timestamps
    end
  end
end
