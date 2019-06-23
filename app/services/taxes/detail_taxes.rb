class DetailTaxes
  prepend Service

  def call
    data = []
    TaxMaster.taxes_to_show.each do |tax_master|
      taxesDetail = Tax.all.select{ |tax| tax.name == tax_master.name and !tax.balance.editable and tax.amount != 0}.map do |tax|
        prepare_tax_registry(tax)
      end

      manualTaxesDetail = tax_master.manual_taxes.map do |manual_tax|
        prepare_manual_tax_registry(manual_tax)
      end
      total_taxes = taxesDetail + manualTaxesDetail
      data.push({name: tax_master.name, years: order_taxes_by_year(total_taxes)})
    end
  data
  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error getting details for taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  private

  def prepare_tax_registry(tax)
    tax.invoice_date = tax.created_at.strftime("%Y-%m-%d") if tax.invoice_date == nil
    {
        balance: {
            id: tax.balance.id,
            client: tax.balance.client,
            project: tax.balance.project,
            description: tax.balance.description
        },
        date: tax.invoice_date,
        amount: tax.amount
    }
  end

  def prepare_manual_tax_registry(manual_tax)
    {
        concept: manual_tax.concept,
        date: manual_tax.date,
        amount: manual_tax.amount
    }
  end

  def order_taxes_by_year (taxes)
    taxes = taxes.sort_by{ |taxDetail| taxDetail[:date] }.reverse
    map = {}
    taxes.each do |tax|
      year = tax[:date].strftime("%Y")
      if map[year]
        map[year].push(tax)
      else
        map[year] = [tax]
      end
    end

    data = []
    map.each do |year,array|
      data.push({year: year, taxDetails: array})
    end
    data
  end

end