class InvoiceHasManyTaxes < ActiveRecord::Migration[5.2]
  def change
    rename_column :taxes, :invoice_id, :invoice_id_alegra
    add_reference :taxes, :invoice, foreign_key: true
  end
end
