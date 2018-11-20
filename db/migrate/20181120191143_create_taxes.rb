class CreateTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :taxes do |t|
      t.string :name
      t.decimal :value
      t.string :type_tax

      t.timestamps
    end
  end
end
