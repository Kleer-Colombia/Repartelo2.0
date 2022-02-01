class Kleerer < ApplicationRecord

  validates :name, presence: true, length: { maximum: 50 }
  has_many :saldos
  belongs_to :option
  has_and_belongs_to_many :coaching_sessions
  has_and_belongs_to_many :objectives

end
