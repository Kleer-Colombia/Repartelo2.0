class CreateExpenses < ActiveRecord::Migration[5.1]
  def change
    create_table :expenses do |t|
      t.belongs_to :balance, index: true
      t.string :description, :null => false
      t.decimal :amount, :null => false
      t.timestamps
    end
  end
end
