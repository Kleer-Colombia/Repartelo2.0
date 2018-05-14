class Saldo < ApplicationRecord
  validates :amount, presence: true
  validates :reference, presence: true
  validates :concept, presence: true
  belongs_to :kleerer
  belongs_to :balance
end