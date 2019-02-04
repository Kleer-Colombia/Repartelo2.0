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
    plus_data(incomes)
  end

  def total_expenses
    plus_data(expenses)
  end

  def calculate_profit
    profit = resume[:utilidad] - find_tax_value(:kleerCo)
    if(profit < 0)
      raise StandardError, 'Nothing to distribute!'
    end
    profit
  end

  def resume
    resume = {}
    resume[:ingresos] = total_incomes
    resume_in_invoice, total_in_invoice = resume_in_invoice_tax
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

  def find_tax_value(name)
    tax = self.taxes.detect { |e| e.name == name.to_s }
    tax ? tax.amount.to_f : 0
  end

  def find_master_taxes
    master_tax_names = TaxMaster.find_master_taxes_names
    master_taxes = taxes.select do |tax|
      master_tax_names.include?(tax.name)
    end
    master_taxes
  end

  def get_invoice_ids
    incomes.select {|income| income.invoice_id}.map {|income| income.invoice_id}
  end
  
  # by default select the most older date
  def find_invoice_date
    older_income = incomes.min_by(&:invoice_date)
    {invoice_id: older_income&.invoice_id, invoice_date: older_income&.invoice_date}
  end

  def find_in_invoice_taxes
    master_tax_names = TaxMaster.find_master_taxes_names
    in_invoice_taxes = taxes.reject do |tax|
      master_tax_names.include?(tax.name)
    end
    in_invoice_taxes
  end

  def resume_in_invoice_tax
    resume = {}
    total = 0
    find_in_invoice_taxes.each do |tax|
      if resume[tax.name]
        resume[tax.name] += tax.amount.to_f
        total += tax.amount.to_f
      else
        resume[tax.name] = tax.amount.to_f
        total = tax.amount.to_f
      end
    end
    return resume, total
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
      total += resume[tax.name]
    end
    return resume, total
  end



end
