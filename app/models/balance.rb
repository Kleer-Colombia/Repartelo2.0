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

  def resume
    resume = {}
    resume[:ingresos] = total_incomes
    resume[:chanchito] = find_tax_value(:chanchito)
    resume[:ica] = find_tax_value(:ica)
    resume[:egresos] = total_expenses
    resume[:pre_utilidad] = resume[:ingresos] - resume[:chanchito] - resume[:ica] - resume[:egresos]
    resume[:retefuente] = find_tax_value(:retefuente)
    resume[:utilidad] = resume[:pre_utilidad] - resume[:retefuente]
    resume[:kleerCo] = find_tax_value(:kleerCo)
    return resume
  end

  private

  def find_tax_value(name)
    tax = self.taxes.detect {|e| e.name == name.to_s}
    tax ? tax.amount.to_f : 0
  end

  def plus_data(data)
    result = 0
    data.each do |item|
      result += item.amount
    end
    result
  end

end
