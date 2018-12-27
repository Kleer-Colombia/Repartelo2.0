class Balance < ApplicationRecord
  validates :client, presence: true, allow_blank: false
  validates :project, presence: true, allow_blank: false
  validates :balance_type, presence: true, allow_blank: false
  has_many :incomes, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :taxes, dependent: :destroy
  has_many :distributions, dependent: :destroy
  has_many :percentages, dependent: :destroy


  def total_incomes
    plus_data(self.incomes)
  end

  def total_expenses
    plus_data(self.expenses)
  end

  private

  def plus_data(data)
    result = 0
    data.each do |item|
      result += item.amount
    end
    result
  end

end
