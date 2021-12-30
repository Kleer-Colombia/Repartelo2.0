class CreateObjectives < ActiveRecord::Migration[5.2]
  def change
    create_table :objectives do |t|
      t.decimal :amount
      t.belongs_to :kleerer, index: true, :null => false
      t.timestamps
    end
  end
end
