class TaxMaster < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true
  validates :type_tax, presence: true


  def self.find_taxes(type)
    where(type_tax: type)
  end

  def self.taxes_names_to_calculate
    where.not(name: 'IVA').map(&:name)
  end

  def self.taxes_names_to_show
    where.not(name: 'kleerCo').map(&:name)
  end


end
