class TaxMaster < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true
  validates :type_tax, presence: true


  def self.find_taxes(type)
    where(type_tax: type)
  end

  def self.find_master_taxes_names
    all.map(&:name)
  end


end
