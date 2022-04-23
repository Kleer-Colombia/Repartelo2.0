class Country < ApplicationRecord
  has_many :clearing, dependent: :destroy
end
