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
              # otra_lectura: call_new)
  rescue StandardError => error
    puts error.to_s #TODO improve the logs
    errors.add(:messages, "error getting details for taxes: #{error.message}")
    errors.add(:error_code, :not_acceptable)
  end

  def call_new
    tax_master = TaxMaster.find(@taxId)
    data = Tax.where(tax_id: tax_master.id)
    summary = {total: 0, ingresos: 0, egresos: 0}
    summary = calculate_totals(data, summary)
    summary[:meses] = calculate_by_month data
  end

  def calculate_totals(data, summary)
    data.each do |tax|
      if tax.amount < 0
        summary[:egresos] += tax.amount
      else
        summary[:ingresos] += tax.amount
      end
      summary[:total] += tax.amount
    end
    return summary
  end

  #TODO: get out in high abstraction level this month distribution
  def calculate_totals_by_month data, all_taxes
    month_array = []
    months = data.group_by{|e| e.created_at.strftime('%Y-%M')}

    months.each do |month_name, data|
      month = {total: 0, fecha: month_name}
      month = calculate_totals(data, month)
      month[:detalles] = prepare_details(data)

      month_array.push(month)
    end

    acum = 0

    month_array.reverse.each do |month|
      acum += month[:total]
      month[:saldo_acumulado] = acum
    end

    return month_array
  end

  def prepare_details(data)
    details = []
    data.each do |tax|
      concept = "ola"

      detail = {ingreso: '',concepto: concept, reference: "/"}

      if tax.amount < 0
        details[:egreso] = tax.amount
      else
        detail[:ingreso] = tax.amount
      end

      details.push(detail)
    end
    return details
  end

end
