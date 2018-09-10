class Kleerer < ApplicationRecord

  validates :name, presence: true, length: { maximum: 50 }
  validates :option, presence: true, length: { maximum: 50 }
  has_many :saldos
  has_many :kleererOnCoachingSessions
  has_many :coachingSessions, through: :kleererOnCoachingSessions

end