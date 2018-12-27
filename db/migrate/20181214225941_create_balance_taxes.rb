class CreateBalanceTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :taxes do |t|
      t.belongs_to :balance, index: true
      t.string :name, :null => false
      t.decimal :amount, :null => false
      t.decimal :percentage, :null => false
      t.timestamps
    end
  end
end
