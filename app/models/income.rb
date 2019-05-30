class Income < ApplicationRecord
  validates :description, presence: true
  validates :amount, presence: true
  belongs_to :invoice, optional: true, required: false, :dependent => :destroy
end