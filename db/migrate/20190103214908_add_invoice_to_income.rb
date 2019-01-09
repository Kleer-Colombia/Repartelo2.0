class AddInvoiceToIncome < ActiveRecord::Migration[5.2]
  def change
    add_column :incomes, :invoice_id, :integer, default: '', null: true
    add_column :incomes, :invoice_date, :date, default: '', null: true
  end
end
