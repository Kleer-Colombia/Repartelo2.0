class Income < ApplicationRecord
  validates :description, presence: true
  validates :amount, presence: true
  belongs_to :balance, optional: true
  has_one :invoice,  required: false, :dependent => :destroy
end
