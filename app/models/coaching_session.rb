class CoachingSession < ApplicationRecord

  validates :date, presence: true
  validates :description, presence: true
  has_and_belongs_to_many :kleerers
  belongs_to :balance

end
