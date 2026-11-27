class Saldo < ApplicationRecord
  validates :amount, presence: true
  validates :reference, presence: true
  validates :concept, presence: true
  # Carga manual (pantalla Saldos > Agregar registro): un monto 0 no tiene
  # sentido. Solo en ese contexto, para no afectar saldos automáticos
  # (distribuciones, carga de gastos) que podrían ser 0.
  validates :amount, numericality: { other_than: 0 }, on: :manual
  belongs_to :kleerer
  belongs_to :balance, optional: true
end