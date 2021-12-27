class SaldosActions

  def find_saldos kleerer_id
    data = Saldo.where(kleerer_id: kleerer_id).order(created_at: :desc)
    summary = { total: 0, ingresos: 0, egresos: 0}
    summary = calculate_totals data, summary
    summary[:meses] = calculate_totals_by_month data, true
    return summary
  end

  def find_saldos_of_balances kleerer_id
    data = Saldo.where(kleerer_id: kleerer_id).order(created_at: :desc)
    summary = { total: 0, ingresos: 0, egresos: 0}
    summary = calculate_totals_of_balances data,summary
    summary[:meses] = calculate_totals_by_month data, false
    return summary
  end

  def add_saldo options
    if(options[:distribution])
      add_saldo_with_distribution options[:distribution], options[:balance]
    elsif(options[:saldo])
      add_saldo_with_saldo options[:saldo]
    else
      raise StandardError,"invalid options for add saldo #{options}"
    end
  end



  private

  def add_saldo_with_distribution distribution, balance
    saldo = Saldo.new(amount: distribution.amount, kleerer_id: distribution.kleerer_id,
                      balance_id: balance.id, reference: "/balance/#{balance.id}",
                      concept: "Ingreso del proyecto: #{balance.description}")
    saldo.save!
  end

  #TODO validate if saldo is a number, and if reference is and URL ... you cant try to add a validation framework?
  def add_saldo_with_saldo saldo
    saldo = Saldo.new(amount: saldo[:amount], kleerer_id: saldo[:kleerer_id],
                      reference: saldo[:reference],
                      concept: saldo[:concept], created_at: saldo[:date], updated_at: saldo[:date])
    saldo.save!
  end

  def calculate_totals data, summary
    data.each do |saldo|
      if saldo.amount < 0
        summary[:egresos] += saldo.amount
      else
        summary[:ingresos] += saldo.amount
      end
      summary[:total] += saldo.amount
    end
    return summary
  end



  def calculate_totals_by_month data, all_saldos
    month_array = []

    if all_saldos
      months = separate_in_months data
    else
      months = separate_in_months_with_balance data
    end

    months.each do |month_name, data|
      month = { total: 0, ingresos: 0, egresos: 0, fecha: month_name}
      month = calculate_totals data, month
      month[:detalles] = prepare_details data
      month_array.push(month)
    end

    return month_array
  end

  def separate_in_months data
    months = {}
    data.each do |saldo|
      months = get_one_month_saldos saldo, months
    end
    return months
  end

  def prepare_details data
    details = []
    data.each do |saldo|
      detail = {ingreso: '',egreso: '',
                 referencia: saldo.reference,concepto: saldo.concept,
                 fecha: saldo.created_at.strftime('%d')}
      if saldo.amount < 0
        detail[:egreso] = saldo.amount
      else
        detail[:ingreso] = saldo.amount
      end
      details.push(detail)
    end
    return details
  end

  #Saldos with balance

  def calculate_totals_of_balances data, summary
    data.each do |saldo|
      if saldo.balance
        if saldo.amount < 0
          summary[:egresos] += saldo.amount
        else
          summary[:ingresos] += saldo.amount
        end
        summary[:total] += saldo.amount
      end
    end
    return summary
  end

  def separate_in_months_with_balance data
    months = {}
    data.each do |saldo|
      if saldo.balance
        months = get_one_month_saldos saldo, months
      end
    end
    return months
  end

  # Generals
  def get_one_month_saldos saldo, months
    date = saldo.created_at.strftime('%Y-%m')
    unless months[date]
      months[date] = []
    end
    months[date].push saldo

    return months
  end


end
