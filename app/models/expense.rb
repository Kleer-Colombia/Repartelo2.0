class Expense < ApplicationRecord
  validates :description, presence: true
  validates :amount, presence: true
end