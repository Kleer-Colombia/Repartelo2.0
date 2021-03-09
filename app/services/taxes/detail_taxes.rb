class DetailTaxes < TaxesHelper
  prepend Service

  def call
    data = []
    TaxMaster.taxes_to_show.each do |tax_master|
      taxesDetail = Tax.all.select{ |tax| tax.name.split(' (')[0] == tax_master.name and !tax.balance.editable and tax.amount != 0}.map do |tax|
        prepare_tax_registry(tax)
      end

      manualTaxesDetail = tax_master.manual_taxes.map do |manual_tax|
        prepare_manual_tax_registry(manual_tax)
      end
      total_taxes = taxesDetail + manualTaxesDetail
      data.push({name: tax_master.name, id: tax_master.id, years: order_taxes_by_year(total_taxes)})
    end
  data
  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error getting details for taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end
end