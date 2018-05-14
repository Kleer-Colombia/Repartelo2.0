class CreateDistributions < ActiveRecord::Migration[5.1]
  def change
    create_table :distributions do |t|
      t.belongs_to :balance, index: true, :null => false
      t.belongs_to :kleerer, index: true, :null => false
      t.decimal :amount, :null => false
      t.timestamps
    end
  end
end
