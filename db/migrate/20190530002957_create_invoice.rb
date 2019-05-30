class CreateInvoice < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      #n to n relation between incomes an invoices
      t.belongs_to :income, index: true
      t.decimal :invoice_id
      t.decimal :percentage
      t.date :date
      t.timestamps
    end
  end
end
