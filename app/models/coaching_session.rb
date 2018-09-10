class CoachingSession < ApplicationRecord

  validates :date, presence: true
  validates :description, presence: true
  has_many :kleererOnCoachingSessions
  has_many :kleerers, through: :kleererOnCoachingSessions
  belongs_to :balance

end
