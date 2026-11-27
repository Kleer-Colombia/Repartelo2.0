# Pago de una factura de venta, cargado en la sección Pagos (o traído de
# Alegra en la migración inicial). Las retenciones de acá son las que usan
# los balances que incluyen la factura.
class InvoicePayment < ApplicationRecord
  SOURCES = %w[repartelo alegra].freeze

  belongs_to :sales_invoice

  validates :source, inclusion: { in: SOURCES }
  validates :paid_on, presence: true, if: -> { source == 'repartelo' }
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { source == 'repartelo' }
  validates :retefuente, :reteica, :reteiva, numericality: { greater_than_or_equal_to: 0 }

  def retentions
    SalesInvoice::RETENTION_KINDS.each_with_object({}) { |kind, h| h[kind] = send(kind).to_f }
  end
end
