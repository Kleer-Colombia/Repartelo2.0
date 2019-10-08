# frozen_string_literal: true

class Tax < ApplicationRecord
  validates :name, presence: true
  validates :amount, presence: true
  validates :percentage, presence: true
  belongs_to :balance
  belongs_to :invoice, required: false

  def self.get_tax_from(name, balance_id)
    tax = Tax.where(name: name).where(balance_id: balance_id)
    if(tax.size == 0)
      " Chanchito no calculado"
    else
      "#{tax[0].name}: #{tax[0].amount}"
    end
  end
end
