class AddInvoiceToTax < ActiveRecord::Migration[5.2]
  def change
    add_column :taxes, :invoice_id, :integer, default: '', null: true
    add_column :taxes, :invoice_date, :date, default: '', null: true
  end
end
