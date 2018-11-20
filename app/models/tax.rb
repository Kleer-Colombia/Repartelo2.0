class Tax < ApplicationRecord
  #TODO poner en activeAdmin
  validates :name, presence: true
  validates :value, presence: true
  validates :type_tax, presence: true
end
