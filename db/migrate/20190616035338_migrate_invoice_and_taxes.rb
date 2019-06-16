class MigrateInvoiceAndTaxes < ActiveRecord::Migration[5.2]
  def change
    Tax.all.each do |tax|
      id_alegra = tax.invoice_id_alegra
      if id_alegra
        invoices = Invoice.where(invoice_id: id_alegra)
        if invoices
          invoices.each do |invoice|
            if(invoice.income.balance_id == tax.balance.id and tax.name == "IVA")
              invoice.taxes << tax
              invoice.save!
            end
          end
        end
      end
    end
  end
end
