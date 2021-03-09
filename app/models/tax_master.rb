class TaxMaster < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true
  validates :type_tax, presence: true
  has_many :manual_taxes


  def self.find_taxes(type)
    where(type_tax: type)
  end

  def self.taxes_names_to_calculate
    where.not(type_tax: 'in_alegra').map(&:name)
  end

  def self.taxes_to_show
    where.not(name: 'kleerCo')
  end

  def self.all_taxes(balance)

    if balance.balance_type == 'standard-international'
      master_taxes = where.not(name: 'Ica')
      master_taxes.each do |master_tax|
        if master_tax.name == 'Retefuente'
          master_tax.value = balance.retencion
        end
      end
    else
      master_taxes = all
    end
    return master_taxes
  end


end
