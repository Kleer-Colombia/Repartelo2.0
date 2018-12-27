class RenameTaxToTaxMaster < ActiveRecord::Migration[5.2]
  def change
    rename_table :taxes, :tax_masters
  end
end
