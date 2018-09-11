class Kleerer < ApplicationRecord

  validates :name, presence: true, length: { maximum: 50 }
  validates :option, presence: true, length: { maximum: 50 }
  has_many :saldos
  has_and_belongs_to_many :coaching_sessions

end