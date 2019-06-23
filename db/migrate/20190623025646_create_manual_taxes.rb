class CreateManualTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :manual_taxes do |t|
      t.string :concept, :null => false
      t.decimal :amount, :null => false
      t.date :date, :null => false
      t.belongs_to :tax_master, index: true
      t.timestamps
    end
  end
end
