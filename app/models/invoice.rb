class Invoice < ApplicationRecord
  validates :percentage, presence: true
  validates :invoice_id, presence: true
  validates :date, presence: true
  belongs_to :income
end