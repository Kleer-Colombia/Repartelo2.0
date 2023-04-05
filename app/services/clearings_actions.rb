class ClearingsActions

  def find_clearings country_id
    #just clearings with amounts are closed
    data = Clearing.where(country_id: country_id).order(created_at: :desc).filter{|e| e.amount}
    data = data.filter{|e| !e.final_amount.nil?}

    summary = { total: 0}
    summary = calculate_totals data, summary
    summary[:meses] = calculate_totals_by_month data
    return summary
  end

  private

  def calculate_totals data, summary
    data.each do |clearing|
      # if clearing.amount < 0
      #   summary[:egresos] += clearing.amount
      # else
      #   summary[:ingresos] += clearing.amount
      # end
      summary[:total] += clearing.amount
    end
    return summary
  end



  def calculate_totals_by_month data
    month_array = []
    months = data.group_by{|e| e.created_at.strftime('%Y-%m')}

    months.each do |month_name, data|
      month = { total: 0, fecha: month_name}
      month = calculate_totals data, month
      month[:detalles] = prepare_details data
      month_array.push(month)
    end

    acum = 0

    month_array.reverse.each do |month|
      acum += month[:total]
      month[:saldo_acumulado] = acum
    end
    return month_array
  end

  def prepare_details data
    details = []
    data.each do |clearing|
      concept = "Balance: #{clearing.balance_id} - #{clearing.balance.client} - #{clearing.description}"

      detail = {ingreso: '',concepto: concept,  reference: "/balance/#{clearing.balance.id}",
                 fecha: clearing.updated_at.strftime('%d-%m-%Y'), extKleerer: clearing.ext_kleerer}
      if clearing.amount < 0
        # detail[:egreso] = saldo.amount
      else
        detail[:ingreso] = clearing.amount
      end
      details.push(detail)
    end
    return details
  end

end
