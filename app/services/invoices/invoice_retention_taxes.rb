# Retenciones de una factura dentro de un balance, a partir de su pago (la
# sección Pagos es la única fuente). Se prorratean por el porcentaje de la
# factura que usa el balance. Mismo criterio que con Alegra: RETEIVA va en
# negativo (no suma al total retenido; ver Balance#resume_in_invoice_tax).
class InvoiceRetentionTaxes
  NAMES = { 'retefuente' => 'RETEFUENTE', 'reteica' => 'RETEICA', 'reteiva' => 'RETEIVA' }.freeze

  def initialize(invoice, sales_invoice = invoice.sales_invoice)
    @invoice = invoice
    @sales_invoice = sales_invoice
  end

  # [Tax] sin guardar (balance e invoice asignados).
  def build(balance)
    payment = @sales_invoice&.payment
    return [] unless payment

    NAMES.filter_map do |kind, name|
      value = payment.send(kind).to_f
      next unless value.positive?

      amount = prorate(value)
      amount *= -1 if kind == 'reteiva'
      Tax.new(name: name, amount: amount, percentage: percentage_of_base(value), invoice: @invoice, balance: balance)
    end
  end

  # Reemplaza en el balance las retenciones de esta factura por las del pago
  # actual. "Retención" = todo impuesto de la factura que no sea de un ítem
  # (IVA, etc.); así también reemplaza las que se guardaron con nombres de
  # Alegra, ej. "RETEFUENTE (Honorarios y comisiones)".
  def replace_in(balance)
    item_taxes = @sales_invoice&.line_tax_names || ['IVA']
    @invoice.taxes.reject { |tax| item_taxes.include?(tax.name) }.each(&:destroy)
    build(balance).each(&:save!)
  end

  private

  def prorate(value)
    ((value * @invoice.percentage.to_f) / 100).round(2)
  end

  # Porcentaje de la retención sobre la base en COP (informativo).
  def percentage_of_base(value)
    base = @sales_invoice.subtotal.to_f
    base *= @sales_invoice.exchange_rate.to_f if @sales_invoice.foreign_currency?
    base.positive? ? ((value / base) * 100).round(2) : 0
  end
end
