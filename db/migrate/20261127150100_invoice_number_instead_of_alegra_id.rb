# Las facturas usadas en balances pasan a identificarse por su número
# (ej. FEKL10758) en vez del id interno de Alegra. El id de Alegra queda
# como referencia histórica en alegra_id; `number` lo completa la tarea
# `bin/rails facturas:migrar_alegra`.
class InvoiceNumberInsteadOfAlegraId < ActiveRecord::Migration[5.2]
  def change
    rename_column :invoices, :invoice_id, :alegra_id
    change_column_null :invoices, :alegra_id, true
    add_column :invoices, :number, :string
    add_index :invoices, :number
  end
end
