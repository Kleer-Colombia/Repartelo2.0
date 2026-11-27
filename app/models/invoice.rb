# Uso (total o parcial, por porcentaje) de una factura de venta en un
# balance. Se identifica por `number` (ej. FEKL10758). `alegra_id` es el id
# interno que se usaba con Alegra; queda solo como referencia histórica.
class Invoice < ApplicationRecord
  validates :percentage, presence: true
  validates :number, presence: true, on: :create
  validates :date, presence: true
  belongs_to :income
  has_many :taxes, dependent: :destroy

  def sales_invoice
    SalesInvoice.find_by(number: number) if number
  end

  # {número => porcentaje usado sumando todos los balances}
  def self.used_percentages
    where.not(number: nil).group(:number).sum(:percentage).transform_values(&:to_f)
  end
end
