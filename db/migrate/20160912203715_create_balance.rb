class CreateBalance < ActiveRecord::Migration[5.1]
    def change
     create_table :balances do |t|
       t.string :client, :null => false
       t.string :project, :null => false
       t.date :date, :null => false
       t.string :description
       t.timestamps
     end
   end
end
