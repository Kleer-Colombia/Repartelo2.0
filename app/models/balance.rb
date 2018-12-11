class Balance < ApplicationRecord
  validates :client, presence: true, allow_blank: false
  validates :project, presence: true, allow_blank: false
  validates :balance_type, presence: true, allow_blank: false
  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :distributions, dependent: :destroy
  has_many :percentages, dependent: :destroy
end
