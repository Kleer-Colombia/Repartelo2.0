class MigrateInvoice < ActiveRecord::Migration[5.2]
  def change
    Income.where.not(invoice_id: [nil]).each do |income|
      income.create_invoice!(income: income,
                             invoice_id: income.invoice_id,
                             date: income.invoice_date,
                             percentage: 100)
    end
    remove_column :incomes, :invoice_id, :integer
    remove_column :incomes, :invoice_date, :date
  end
end
