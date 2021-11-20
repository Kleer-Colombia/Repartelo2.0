ActiveAdmin.register ManualTax do
  permit_params :concept, :date, :payment_date, :amount, :tax_master
end
