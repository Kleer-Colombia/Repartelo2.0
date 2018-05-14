class Balance < ApplicationRecord
  validates :client, presence: true
  validates :project, presence: true
  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :distributions, dependent: :destroy
  has_many :percentages, dependent: :destroy
end
