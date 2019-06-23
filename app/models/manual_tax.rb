class ManualTax < ApplicationRecord
  validates :concept, presence: true
  validates :date, presence: true
  validates :payment_date, presence: true
  validates :amount, presence: true
  belongs_to :tax_master

  def self.find_by_master_and_year(taxMasterId,year)
    where(tax_master_id: taxMasterId).where('extract(year from date) = ?', year)
  end


end
