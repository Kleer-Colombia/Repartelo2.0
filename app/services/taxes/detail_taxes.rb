class DetailTaxes
  prepend Service

  def call
    data = []

    TaxMaster.find_master_taxes_names.select{|name| name!=:kleerCo.to_s }.each do |name|
      taxesDetail = Tax.all.select{ |tax| tax.name == name }.map do |tax|
        {
           balance: {
               balanceId: tax.balance.id,
               balanceClient: tax.balance.client,
               balanceProject: tax.balance.project,
               balanceDescription: tax.balance.description
           },
           date: tax.created_at,
           amount: tax.amount
        }
      end
      data.push({name: name, detail: taxesDetail})
    end
  data
  rescue StandardError => error
    puts error
    errors.add(:messages, "error getting details for taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

end