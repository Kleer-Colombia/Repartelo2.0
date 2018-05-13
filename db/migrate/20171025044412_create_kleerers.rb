class CreateKleerers < ActiveRecord::Migration[5.1]
  def change
    #TODO make name unique
    create_table :kleerers do |t|
      t.string :name, :null => false
      t.string :option, :null => false
      t.timestamps
    end
  end
end
