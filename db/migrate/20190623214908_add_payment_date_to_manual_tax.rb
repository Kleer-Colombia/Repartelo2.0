class AddPaymentDateToManualTax < ActiveRecord::Migration[5.2]
  def change
    add_column :manual_taxes, :payment_date, :date, null: false
  end
end