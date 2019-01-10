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
    resume_in_invoice, total_in_invoice = find_tax(:in_invoice)
    resume.merge!(resume_in_invoice)
    resume_invoiced, total = find_tax(:invoiced)
    resume.merge!(resume_invoiced)
    resume[:egresos] = total_expenses
    resume[:pre_utilidad] = resume[:ingresos] - resume[:egresos] - total - total_in_invoice
    resume_utility, total_utility = find_tax(:utility)
    resume.merge!(resume_utility)
    resume[:utilidad] = resume[:pre_utilidad] - total_utility
    return resume
  end

  def calculate_profit

    profit = resume[:utilidad] - find_tax_value(:kleerCo)
    if(profit < 0)
      raise StandardError, 'Nothing to distribute!'
    end
    profit
  end

  def find_tax_value(name)
    tax = self.taxes.detect {|e| e.name == name.to_s}
    tax ? tax.amount.to_f : 0
  end

  def find_master_taxes
    master_tax_names = TaxMaster.all.map(&:name)
    master_taxes = taxes.select do |tax|
      master_tax_names.include?(tax.name)
    end
    master_taxes
  end

  def find_other_taxes
    master_tax_names = TaxMaster.all.map(&:name)
    other_taxes = taxes.reject do |tax|
      master_tax_names.include?(tax.name)
    end
    other_taxes
  end

  private

  def plus_data(data)
    result = 0
    data.each do |item|
      result += item.amount
    end
    result
  end

  def find_tax(type)
    resume = {}
    total = 0
    TaxMaster.find_taxes(type).each do |tax|
      resume[tax.name] = find_tax_value(tax.name)
      total+= resume[tax.name]
    end
    return resume, total
  end

end
