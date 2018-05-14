class Kleerer < ApplicationRecord

  validates :name, presence: true, length: { maximum: 50 }
  validates :option, presence: true, length: { maximum: 50 }
  has_many :saldos

end