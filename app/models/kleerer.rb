class Kleerer < ApplicationRecord

  scope :colombia, -> { find_by_name('KleerCo') }

  validates :name, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: true

  has_many :saldos
  belongs_to :option
  has_many :coaching_sessions
  has_many :kleerers_objectives
  has_many :objectives, through: :kleerers_objectives
end
