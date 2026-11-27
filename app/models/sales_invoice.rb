# Factura de venta tal como está en el Drive de contabilidad (XML DIAN).
# Se carga con DriveInvoices::Sync; no se edita a mano.
class SalesInvoice < ApplicationRecord
  RETENTION_KINDS = %w[retefuente reteica reteiva].freeze

  has_one :payment, class_name: 'InvoicePayment', dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :issue_date, presence: true

  scope :not_annulled, -> { where(annulled_by: nil) }
  scope :unpaid, -> { left_joins(:payment).where(invoice_payments: { id: nil }) }
  scope :paid, -> { joins(:payment) }

  # Clasifica el nombre de una retención (de Alegra o del XML) en uno de los
  # tres tipos: "ReteIVA" → reteiva, "Reteica Bogotá 2022" → reteica,
  # "Honorarios y comisiones" / "Servicios en general" → retefuente.
  def self.retention_kind_for(name)
    translated = TaxMaster.translate_tax_name(name.to_s).to_s
    return translated.downcase if %w[RETEFUENTE RETEICA RETEIVA].include?(translated)
    return 'reteiva' if name.to_s =~ /rete\s*iva|\biva\b/i
    return 'reteica' if name.to_s =~ /rete\s*ica|\bica\b/i

    'retefuente'
  end

  def foreign_currency?
    currency.present? && currency != 'COP'
  end

  def annulled?
    annulled_by.present?
  end

  def paid?
    payment.present?
  end

  # Ítems de facturas usados en balances (tabla invoices) que apuntan a esta.
  def balance_invoices
    Invoice.includes(income: :balance).where(number: number)
  end

  def used_in_closed_balance?
    balance_invoices.any? { |inv| inv.income&.balance && !inv.income.balance.editable }
  end

  # Nombres de los impuestos de los ítems (ej. "IVA"): sirven para distinguir,
  # entre los impuestos que un balance guarda para esta factura, cuáles son
  # retenciones (todo lo demás).
  def line_tax_names
    lines.flat_map { |line| (line['taxes'] || []).map { |tax| tax['name'] } }.compact.uniq
  end
end
