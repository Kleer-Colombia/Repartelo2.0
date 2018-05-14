class CreateSaldos < ActiveRecord::Migration[5.1]
  def change
    create_table :saldos do |t|
      t.belongs_to :balance, index: true, :null => true
      t.belongs_to :kleerer, index: true, :null => false
      t.decimal :amount, :null => false
      t.string :reference, :null => false
      t.string :concept, :null => false
      t.timestamps
    end
  end
end
