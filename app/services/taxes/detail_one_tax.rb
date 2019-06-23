class DetailOneTax < TaxesHelper
  prepend Service

  attr_accessor :taxId,:taxYear
  def initialize(taxId, taxYear)
    @taxId = taxId
    @taxYear = taxYear
  end

  def call
    data = []
    tax_master = TaxMaster.find(@taxId)
    taxesDetail = Tax.all.select{ |tax|
                                  tax.name == tax_master.name and
                                  !tax.balance.editable and
                                  tax.amount != 0 and
                                  (tax.invoice_date&.strftime("%Y") == @taxYear or
                                      tax.created_at.strftime("%Y") == @taxYear)
                                }.map do |tax|
      prepare_tax_registry(tax)
    end

    manualTaxesDetail = ManualTax.find_by_master_and_year(@taxId,@taxYear).map do |manual_tax|
      prepare_manual_tax_registry(manual_tax)
    end

    total_taxes = taxesDetail + manualTaxesDetail
    data.push({name: tax_master.name, id: tax_master.id, years: order_taxes_by_year(total_taxes)})

  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error getting details for taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end