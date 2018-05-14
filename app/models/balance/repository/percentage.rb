class Percentage < ApplicationRecord
  validates :value, presence: true
  belongs_to :kleerer
  belongs_to :balance
end