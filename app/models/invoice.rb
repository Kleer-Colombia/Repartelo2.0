class Invoice < ApplicationRecord
  validates :percentage, presence: true
  validates :invoice_id, presence: true
  validates :date, presence: true
  belongs_to :income
  has_many :taxes, dependent: :destroy

  def self.find_invoice_with_percentage_unused
    invoices = Invoice.where.not(percentage: 100)
    invoices_ids_to_remove = find_invoice_ids_to_remove(invoices)
    invoices.select{|invoice| !invoices_ids_to_remove.include?(invoice.invoice_id)}
  end

  def self.find_invoice_with_percentage_used_at_all
    invoices = Invoice.all
    invoices_ids_to_remove = find_invoice_ids_to_remove(invoices)
    invoices.select{|invoice| invoices_ids_to_remove.include?(invoice.invoice_id)}
  end

  private

  def self.find_invoice_ids_to_remove(invoices)
    totals = {}
    invoices_ids_to_remove = []
    invoices.each do |invoice|
      if(totals[invoice.invoice_id])
        totals[invoice.invoice_id] += invoice.percentage
      else
        totals[invoice.invoice_id] = invoice.percentage
      end

      if(totals[invoice.invoice_id] >= 100)
        invoices_ids_to_remove << invoice.invoice_id
      end
    end

    invoices_ids_to_remove
  end
end