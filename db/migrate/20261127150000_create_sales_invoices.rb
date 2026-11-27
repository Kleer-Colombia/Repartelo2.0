# Facturas de venta leídas del Drive de contabilidad (XML DIAN), sus pagos
# y el registro de qué archivos del Drive ya se procesaron. Reemplaza la
# consulta en vivo a Alegra (ver app/services/drive_invoices/).
class CreateSalesInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_invoices do |t|
      # Número completo con prefijo, tal como viene en el XML (ej. FEKL10758).
      # Es el identificador de la factura en todo Repártelo.
      t.string :number, null: false
      t.string :cufe
      t.string :type_code
      t.date :issue_date, null: false
      t.date :due_date
      t.string :client_name
      t.string :client_nit
      t.string :currency, null: false, default: 'COP'
      t.decimal :exchange_rate
      t.decimal :subtotal, null: false, default: 0
      t.decimal :tax_total, null: false, default: 0
      t.decimal :total, null: false, default: 0
      # [{description, quantity, price, line_total, discount, taxes: [{name, percent, amount}]}]
      t.jsonb :lines, null: false, default: []
      # Retenciones conocidas antes del pago (de Alegra en la migración, o del
      # XML si el proveedor las informa): {retefuente, reteica, reteiva}.
      # Solo precargan el formulario de Pagos.
      t.jsonb :suggested_retentions, null: false, default: {}
      t.string :drive_file_id
      t.string :drive_path
      t.string :annulled_by
      t.date :annulled_on
      t.string :alegra_status
      t.timestamps
    end
    add_index :sales_invoices, :number, unique: true
    add_index :sales_invoices, :cufe
    add_index :sales_invoices, :issue_date

    create_table :invoice_payments do |t|
      t.references :sales_invoice, null: false, foreign_key: true, index: { unique: true }
      # nil solo en pagos traídos de Alegra (no exponemos la fecha de pago).
      t.date :paid_on
      t.decimal :amount
      t.decimal :retefuente, null: false, default: 0
      t.decimal :reteica, null: false, default: 0
      t.decimal :reteiva, null: false, default: 0
      # 'repartelo' (cargado en Pagos) o 'alegra' (migración inicial).
      t.string :source, null: false, default: 'repartelo'
      t.string :registered_by
      t.timestamps
    end

    create_table :drive_files do |t|
      t.string :drive_id, null: false
      t.string :name
      t.string :path
      # invoice_xml | credit_note | folder | other
      t.string :kind, null: false
      # processed | ignored | error | done (carpeta ya leída)
      t.string :status, null: false
      t.text :error
      # Notas crédito: {cufes: [...], numbers: [...]} que referencia.
      t.jsonb :doc_refs, null: false, default: {}
      t.references :sales_invoice, foreign_key: true
      t.timestamps
    end
    add_index :drive_files, :drive_id, unique: true

    create_table :drive_sync_runs do |t|
      t.string :mode, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.jsonb :summary, null: false, default: {}
      t.text :error
    end
  end
end
