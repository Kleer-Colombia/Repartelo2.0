class Objective < ApplicationRecord
  has_many :kleerers_objectives
  has_many :kleerers, through: :kleerers_objectives
end
