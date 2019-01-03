class CreateKleerers < ActiveRecord::Migration[5.1]
  def change
    create_table :kleerers do |t|
      t.string :name, :null => false
      t.string :option, :null => false
      t.timestamps
    end
  end
end
