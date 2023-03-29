class Kleerer < ApplicationRecord

  validates :name, presence: true, length: { maximum: 50 }
  has_many :saldos
  belongs_to :option
  has_many :coaching_sessions
  has_many :kleerers_objectives
  has_many :objectives, through: :kleerers_objectives
end
