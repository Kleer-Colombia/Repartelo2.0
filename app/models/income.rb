class Income < ApplicationRecord
  validates :description, presence: true
  validates :amount, presence: true
  has_one :invoice,  required: false, :dependent => :destroy
end