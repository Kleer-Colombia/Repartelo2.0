class ManualTax < ApplicationRecord
  validates :concept, presence: true
  validates :date, presence: true
  validates :amount, presence: true
  belongs_to :tax_master
end
