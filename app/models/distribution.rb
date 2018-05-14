class Distribution < ApplicationRecord
  validates :amount, presence: true
  belongs_to :kleerer
  belongs_to :balance
end