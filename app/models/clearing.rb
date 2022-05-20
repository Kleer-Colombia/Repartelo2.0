class Clearing < ApplicationRecord
  has_one :country
  belongs_to :balance
end
