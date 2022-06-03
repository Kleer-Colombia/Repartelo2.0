class TaxesHelper

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
        amount: tax.amount,
        created_at: tax.created_at
    }
  end

  def prepare_manual_tax_registry(manual_tax)
    {
        concept: manual_tax.concept,
        date: manual_tax.date,
        amount: manual_tax.amount,
        created_at: manual_tax.created_at
    }
  end

  def order_taxes_by_month(taxes)
    summary = {total: 0, ingresos: 0, egresos: 0}
    summary = calculate_totals(taxes, summary)
    summary[:meses] = calculate_totals_by_month(taxes)
  end

  def calculate_totals(data, summary)

    data.each do |tax|
      if tax[:amount] < 0
        summary[:egresos] += tax[:amount]
      else
        summary[:ingresos] += tax[:amount]
      end
      summary[:total] += tax[:amount]
    end
    return summary
  end

  def calculate_totals_by_month data
    month_array = []
    months = data.group_by{|e| e[:created_at].strftime('%Y-%m')}

    months.each do |month_name, data|
      month = {total: 0, ingresos: 0, egresos: 0, fecha: month_name}
      month = calculate_totals(data, month)
      month[:detalles] = data

      month_array.push(month)
    end

    acum = 0


    month_array = month_array.sort_by{|e| DateTime.parse(e[:fecha] + '-01')}


    month_array.each do |month|
      acum += month[:total]
      # puts "#{month[:fecha]} - #{month[:total]} - #{acum}"
      month[:saldo_acumulado] = acum
    end
    return month_array.reverse
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
