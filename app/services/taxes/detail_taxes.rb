class DetailTaxes < TaxesHelper
  prepend Service

  def call
    data = []
    taxes_preconsolidated = {} #{ica: {id: ... ,data[]},Donaciones: {id: ... ,data[]}}
    groups = { "RETEICA" => "Ica", "Reteica Bogotá 2022"=> "Ica","RETEFUENTE" => "Reserva Retefuente",  "RETEIVA" => "IVA","Retefuente" => "Reserva Retefuente", "Reteica Envigado"=> "Ica" }

    TaxMaster.taxes_to_show.each do |tax_master|
      taxesDetail = Tax.all.select{ |tax|
        puts "tax.name: #{tax.name}, tax_master.name: #{tax_master.name}, #{tax.balance_id}"
        tax.name.split(' (')[0] == tax_master.name and !tax.balance.editable and tax.amount != 0
      }.map do |tax|
        prepare_tax_registry(tax)
      end
      manualTaxesDetail = tax_master.manual_taxes.map do |manual_tax|
        prepare_manual_tax_registry(manual_tax)
      end
      total_taxes = taxesDetail + manualTaxesDetail
      tax_key_to_group = groups[tax_master.name] ? groups[tax_master.name] : tax_master.name

      if taxes_preconsolidated[tax_key_to_group]
        taxes_preconsolidated[tax_key_to_group][:data] += total_taxes
      else
        taxes_preconsolidated[tax_key_to_group] = {id: tax_master.id, data: total_taxes}
      end
    end

    taxes_preconsolidated.each do |key, value|
      puts "key: #{key}, Value: #{value[:id]}, size: #{value[:data].size}"
      summary = {total: 0, ingresos: 0, egresos: 0}
      data.push({name: key, id: value[:id], months: order_taxes_by_month(value[:data]),
                 years: order_taxes_by_year(value[:data]), header: calculate_totals(value[:data], summary)})
    end
    data
    rescue StandardError => error
      puts error.to_s #TODO improve the logs
      errors.add(:messages, "error getting details for taxes: #{error.message}")
      errors.add(:error_code, :not_acceptable)
  end
end
