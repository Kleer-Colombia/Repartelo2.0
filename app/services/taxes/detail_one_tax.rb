class DetailOneTax
  prepend Service

  def call
    data = []
    TaxMaster.taxes_names_to_show.each do |name|
      taxesDetail = Tax.all.select{ |tax| tax.name == name and !tax.balance.editable and tax.amount != 0}.map do |tax|

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
      taxesDetail = taxesDetail.sort_by{ |taxDetail| taxDetail[:date] }.reverse
      data.push({name: name, detail: taxesDetail})
    end
  data
  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error getting details for taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end