class Kleerer < ApplicationRecord

  validates :name, presence: true, length: { maximum: 50 }
  # El nombre identifica al kleerer en toda la app (pestañas de Saldos,
  # reportes, y "KleerCo" se busca por nombre en los cálculos): no puede
  # repetirse, tampoco con otras mayúsculas.
  validates :name, uniqueness: { case_sensitive: false }
  has_many :saldos
  belongs_to :option
  has_many :coaching_sessions
  has_many :kleerers_objectives
  has_many :objectives, through: :kleerers_objectives
end
