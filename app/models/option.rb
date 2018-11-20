class Option < ApplicationRecord
  #TODO put on activeAdmin
  validates :name, presence: true
  validates :value, presence: true
end
