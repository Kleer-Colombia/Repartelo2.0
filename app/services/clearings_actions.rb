class ClearingsActions

  def find_clearings country_id
    #just clearings with amounts are closed
    data = Clearing.where(country_id: country_id).order(created_at: :desc).filter{|e| e.amount}
    data = data.filter{|e| !e.final_amount.nil?}

    summary = { total: 0, ingresos: 0, egresos: 0}
    summary = calculate_totals data, summary
    summary[:meses] = calculate_totals_by_month data
    summary
  end

  def add_clearing data
    # default is onlyone
    default = Country.find_by(name: 'default')
    Clearing.create!(country_id: default.id, amount: data[:amount], final_amount: data[:amount], ext_kleerer: data[:extKleerer],
                            description: data[:description], percentage: 0)

  end

  private

  def   calculate_totals data, summary
    data.each do |clearing|
      if clearing.final_amount < 0
        summary[:egresos] += clearing.final_amount
      else
        summary[:ingresos] += clearing.final_amount
      end
      summary[:total] += clearing.final_amount
    end
    return summary
  end



  def calculate_totals_by_month data
    month_array = []
    months = data.group_by{|e| e.created_at.strftime('%Y-%m')}

    months.each do |month_name, data|
      month = { total: 0, ingresos: 0, egresos: 0, fecha: month_name}
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
      concept = ''
      if clearing.balance.nil?
        concept = clearing.description
      else
        concept = "Balance: #{clearing.balance_id} - #{clearing.balance.client} - #{clearing.description}"
      end

      detail = {ingreso: '', egreso: '',concepto: concept,  reference: (clearing.balance.nil? ? '' : "/balance/#{clearing.balance.id}"),
                 fecha: clearing.updated_at.strftime('%d-%m-%Y'), extKleerer: clearing.ext_kleerer}

      if clearing.final_amount < 0
        detail[:egreso] = clearing.final_amount
      else
        detail[:ingreso] = clearing.final_amount
      end
      details.push(detail)
    end
    return details
  end

end
