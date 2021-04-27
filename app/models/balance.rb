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
    profit = resume[:utilidad] - find_taxes_value(:post_utility)
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
    resume_invoiced_a, total_a = find_tax(:post_iva)
    resume_invoiced.merge!(resume_invoiced_a)
    total += total_a
    resume.merge!(resume_invoiced)
    resume[:egresos] = total_expenses
    resume[:pre_utilidad] = resume[:ingresos] - resume[:egresos] - total - total_in_invoice
    resume_utility, total_utility = find_tax(:utility)
    resume.merge!(resume_utility)
    resume[:utilidad] = resume[:pre_utilidad] - total_utility
    Rails.logger.info("Resumed taxes IN BALANCE: #{resume}")
    return resume
  end

  def find_tax_value(name)
    tax = self.taxes.detect { |e| e.name == name.to_s }
    tax ? tax.amount.to_f : 0
  end

  def find_taxes_value(type)

    type_names = TaxMaster.where(type_tax: type).map(&:name)
    taxes = self.taxes.select { |e| type_names.include? e.name }
    total = 0
    taxes.each do |tax|
      total += tax ?  tax.amount.to_f : 0
    end
    total
  end

  def find_tax_percentage(name)
    tax = self.taxes.detect { |e| e.name == name.to_s }
    tax ? tax.percentage.to_f : 0 #percentage
  end

  def distribute(profit, kleerCoCustom = nil)
    kleerCo = Kleerer.find_by(name: "KleerCo")

    forKleerCo = kleerCoCustom ? forKleerCo : find_tax_value(:kleerCo)

    distributions = {kleerCo.id => forKleerCo}

    percentages.each do |percentage|
      kleerer = percentage.kleerer
      forKleerer = (profit * percentage.value) / 100
      re_entry = forKleerer * kleerer.option.value * 0.01

      distributions[kleerCo.id] += re_entry
      distributions[kleerer.id] = forKleerer - re_entry
    end
    distributions
  end

  def find_master_taxes
    master_tax_names = TaxMaster.taxes_names_to_calculate
    master_taxes = taxes.select do |tax|
      master_tax_names.include?(tax.name)
    end
    master_taxes
  end

  def get_invoice_ids
    incomes.select {|income| income.invoice&.invoice_id}.map {|income| income.invoice&.invoice_id}
  end
  
  # by default select the most older date
  def find_invoice_date
    incomes_ids = incomes.map { |income| income.id }
    older_invoice = Invoice.where(income_id: incomes_ids).order(:date).first
    {invoice_id: older_invoice&.invoice_id, invoice_date: older_invoice&.date}
  end

  def find_in_invoice_taxes
    master_tax_names = TaxMaster.taxes_names_to_calculate
    in_invoice_taxes = taxes.reject do |tax|
      master_tax_names.include?(tax.name)
    end
    in_invoice_taxes
  end

  def resume_in_invoice_tax
    resume = {}
    total = 0
    find_in_invoice_taxes.each do |tax|

      tax.name = tax.name.split(' (')[0] #removed the last name of the alegra taxes RETEFUENTE (Honorarios y comisiones)

      if resume[tax.name]
        resume[tax.name] += tax.amount.to_f
      else
        resume[tax.name] = tax.amount.to_f
      end

      total += tax.amount.to_f if tax.amount.to_f > 0 # doesn't add reteIVA
    end
    Rails.logger.info("Resume in invoice taxes #{resume}, total: #{total}")
    return resume, total
  end

  def get_incomes_names
    data=[]
    incomes.each do |income|
      data << "#{income.description}: #{income.amount}"
    end
    data.join('||')
  end

  def prepare_distributions distributions
    data = []
    distributions.each do |distribution|
      data.push({kleerer: Kleerer.find(distribution.kleerer_id).name,
                 amount: distribution.amount})
    end
    data = add_other_post_utility data
    return data
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

  def add_other_post_utility data
    post_utility_names = TaxMaster.where(type_tax: :post_utility).where('name != ?', :kleerCo).map(&:name)
    taxes_founded = taxes.select { |tax| post_utility_names.include? tax.name }

    taxes_founded.each do |tax|
      data.push({kleerer: tax.name,
                 amount: tax.amount})
    end
    data
  end





end
