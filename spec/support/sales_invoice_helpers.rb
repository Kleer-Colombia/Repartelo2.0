# Helpers para specs de facturas de venta / pagos.
module SalesInvoiceHelpers
  def create_sales_invoice(number, issue_date: Date.current - 10, subtotal: 1_000_000, **attrs)
    tax = (subtotal * 0.19).round(2)
    SalesInvoice.create!({ number: number, issue_date: issue_date, client_name: 'Cliente', currency: 'COP',
                           subtotal: subtotal, tax_total: tax, total: subtotal + tax,
                           lines: [{ 'description' => 'Servicio', 'quantity' => 1, 'price' => subtotal,
                                     'line_total' => subtotal, 'discount' => 0,
                                     'taxes' => [{ 'name' => 'IVA', 'percent' => 19.0, 'amount' => tax }] }] }
                         .merge(attrs))
  end

  def create_balance(editable: true)
    Balance.create!(client: 'Cliente', project: 'Proyecto', balance_type: 'standard', editable: editable,
                    date: Date.current)
  end

  # Factura usada en un balance (como queda después de "Buscar factura").
  def use_in_balance(balance, sales_invoice, percentage: 100)
    income = balance.incomes.create!(description: "Factura #{sales_invoice.number}", amount: sales_invoice.total)
    income.create_invoice!(number: sales_invoice.number, date: sales_invoice.issue_date, percentage: percentage)
  end
end

RSpec.configure { |config| config.include SalesInvoiceHelpers }
