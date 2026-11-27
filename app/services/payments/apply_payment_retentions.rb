# Cuando se registra, cambia o borra el pago de una factura, actualiza las
# retenciones de esa factura en los balances abiertos que la usan,
# recalcula sus impuestos y, si ya estaban distribuidos, vuelve a
# distribuir (si no, la tabla de distribución queda vieja y no coincide con
# la utilidad). Los balances cerrados no se tocan.
class ApplyPaymentRetentions
  def initialize(sales_invoice)
    @sales_invoice = sales_invoice
  end

  # Devuelve los ids de los balances actualizados.
  def call
    balances = []
    @sales_invoice.balance_invoices.each do |invoice|
      balance = invoice.income&.balance
      next unless balance&.editable

      InvoiceRetentionTaxes.new(invoice, @sales_invoice).replace_in(balance)
      balances << balance
    end
    balances.uniq.each do |balance|
      CalculateTaxes.for_balance(balance.reload).call
      DistributeBalance.new(balance_id: balance.id).call if balance.distributions.any?
    end
    balances.map(&:id).uniq
  end
end
