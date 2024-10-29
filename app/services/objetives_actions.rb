class ObjetivesActions

  FIRST_YEAR = 2018

  #Actually used
  def find_objectives_distributions
    distributed_objectives = []
    available_years = get_kleer_historical_years

    kleerCo = Kleerer.find_by(name: "KleerCo")
    kleerer_income_list = find_kleerers_inputs(kleerCo)

    initial_income_list = Kleerer.all.map{ |e|
      {
        id: e.id,
        name: e.name,
        amount: 0
      }
    }

    available_years.each do |year|
      objectives = Objective.where('extract(year from created_at) = ?', year)
      current_objective = objectives.max_by{|e| e.created_at}
      kleerers = current_objective ? current_objective.kleerers_objectives : []

      kleerer_plane_list = get_income_by_year(kleerer_income_list, kleerers, year)

      distributed_kleerers, initial_income_list = get_objective_calcules(kleerer_plane_list, initial_income_list, current_objective)

      balance = 0
      income = distributed_kleerers.reduce(0){|ac,e| ac + e[:income]}
      initial_income = distributed_kleerers.reduce(0){|ac,e| ac + e[:initial_income]}

      if current_objective
        balance = (income + initial_income) - current_objective.amount
      end


      distributed_objectives.push({
        "kleerers" => distributed_kleerers,
        "objective" => current_objective,
        "income" => income,
        "initial_income" => initial_income,
        "all_objectives" => objectives,
        "year" => year,
        "balance" => balance
      })
    end

    distributed_objectives
  end

  def find_filtered_kleerers kleerCo, kleerers, objectives
    kleerers_with_meta = kleerers.select{|e| e[:hasMeta]}.length
    kleerers_by_year = []

    objectives.each do |objective|
      year = objective[:year]
      objective_amount = objective[:actual].amount
      initial_percentage = objective[:actual].initial_balance_percentage || 0
      personal_objective = objective_amount / kleerers_with_meta
      filtered_kleerers = []

      kleerers.each do |kleerer|
        partial_income = 0
        initial_income = 0
        balance = 0

        if kleerer[:inputs].length != 0
          partial_income = kleerer[:inputs].find{|e| e[:year] == year}
          partial_income = partial_income ? partial_income[:input] : 0

          if kleerer[:hasMeta] #this will be in other table
            total_income = partial_income - initial_income
            balance = total_income - personal_objective
          end
        end

        filtered_kleerers.push({
                        name: kleerer[:name],
                        income: partial_income,
                        balance: balance,
                        hasMeta: kleerer[:hasMeta],
                        anualMeta: personal_objective,
                        initial_percentage: initial_percentage * 0.01,
                        initial_income: 0,
                        total_income: 0
                      })
      end
      kleerers_by_year.push({
                              year: year,
                              kleerers: filtered_kleerers
                            })
    end

    kleerers_by_year = kleerers_by_year.sort{|a,b| a[:year] <=> b[:year] }
    kleerers_by_year.each do |year_of_incomes|
      year = year_of_incomes[:year]
      kleerers = year_of_incomes[:kleerers]

      last_year_kleerers = kleerers_by_year.find{|e| e[:year] == year - 1}
      if last_year_kleerers
        last_year_kleerers = last_year_kleerers[:kleerers]

        kleerers.each do |kleerer|
          last_income = last_year_kleerers.find{|e| e[:name] == kleerer[:name]}
          last_income = last_income ? last_income[:total_income] : 0

          kleerer[:initial_income] = last_income * kleerer[:initial_percentage]
          kleerer[:total_income] = kleerer[:initial_income] + kleerer[:income]
        end
      end
    end

    kleerers_by_year
  end

  def find_kleerers_inputs kleerCo
    kleerers_inputs = []
    kleerers = []

    Kleerer.all.each do |kleerer|
      if kleerer.name != kleerCo.name
        kleerers.push(kleerer)
      end
    end

    kleerers.each do |kleerer|
      input = get_one_kleerer_input(kleerer, kleerCo)
      kleerers_inputs.push(input)
    end
    kleerers_inputs
  end

  def find_objectives
    all_objectives = Objective.all
    years = separate_in_years all_objectives
    objectives = []
    years.each do |year|
      year_objectives = []

      all_objectives.each do |objective|
        if objective.created_at.to_s.include? year.to_s
          year_objectives.push(objective)
        end
      end
      actual_objective = year_objectives.max_by{|h| h[:created_at]}
      objectives.push({
                   year: year,
                   objectives: year_objectives,
                   actual: actual_objective
                 })
    end
    objectives
  end

  #Actually used
  def add_objective data
    new_objective = Objective.new(amount: data[:objective][:amount], initial_balance_percentage: data[:objective][:percentage])
    new_objective.save!

    data[:kleerers].map do |kleerer|
      ob_kleerer = KleerersObjective.new(kleerer_id: kleerer[:id], objective_id: new_objective.id,
                                         has_custom_objective: kleerer[:hasCustomObjective])

      if kleerer[:hasCustomObjective]
        ob_kleerer.objective_amount = kleerer[:customObjective]
      end
      ob_kleerer.save!
    end

    p new_objective
  end

  #Actually used
  def add_kleerer_to_objective(kleerer_id, objective_id)
    kleerer = Kleerer.find(kleerer_id)
    objective = Objective.find(objective_id)

    objective.kleerers.push(kleerer)
    objective.save!
  end

  # private

  def get_income_by_year(all_inputs, current_kleerers, year)
    current_kleerers.map do |kleerer_ob|
      income = all_inputs.find{|e|
        e[:name] == kleerer_ob.kleerer.name
      }

      begin
        income = income[:inputs].find{|e| e[:year] == year}[:input]
      rescue
        income = 0
      end


      {
        name: kleerer_ob.kleerer.name,
        income: income,
        hasMeta: !kleerer_ob.has_custom_objective,
        custom_objective: kleerer_ob.objective_amount
      }
    end
  end

  def get_objective_calcules(kleerers, last_incomes, current_objective)
    kleerers_with_meta = kleerers.count{|e| e[:hasMeta] == true}
    individual_objective = current_objective ?
                             (current_objective.amount / kleerers_with_meta) :
                             0

    kleerers.each do |kleerer|
      initial_income_index = last_incomes.find_index{|e| e[:name] == kleerer[:name]}

      initial_income = last_incomes[initial_income_index]
      initial_income_amount = (initial_income[:amount] * (current_objective.initial_balance_percentage || 0) * 0.01)
      partial_income = kleerer[:income]
      total_income = partial_income + initial_income_amount
      balance = total_income - individual_objective || 0

      if kleerer[:custom_objective]
        balance = total_income - kleerer[:custom_objective] || 0
      end

      kleerer.merge!({
                       income: partial_income,
                       balance: balance,
                       anualMeta: kleerer[:hasMeta] ? individual_objective : kleerer[:custom_objective],
                       initial_income: initial_income_amount,
                       total_income: total_income
                     })

      last_incomes[initial_income_index][:amount] = (balance > 0 && kleerer[:hasMeta]) ? balance : 0

    end
    return kleerers, last_incomes
  end

  def get_one_kleerer_input kleerer, kleerCo
    complete_kleerer_input = {
      name: kleerer.name,
      hasMeta: kleerer.option.name.include?("meta"),
      inputs: []
    }
    saldos = Saldo.where(kleerer_id: kleerer.id)
    inputs = []
    years = separate_in_years saldos
    years.each do |year|
      inputs.push({
                    year: year,
                    input: 0
                  })
    end
    saldos.each do |saldo|
      #that could be better
      if saldo.balance_id
        begin
          balance_input = Saldo.find_by(kleerer_id: kleerCo.id, balance_id: saldo.balance_id)
          percentage = Percentage.find_by(kleerer_id: kleerer.id, balance_id: saldo.balance_id)
          input = balance_input.amount * (percentage.value / 100)
          date = saldo.created_at.strftime('%Y').to_i
          inputs.each do |year_input|
            if year_input[:year] == date
              year_input[:input] = year_input[:input] + input
            end
          end
        rescue
          break
        end
      end
    end
    complete_kleerer_input[:inputs] = inputs
    complete_kleerer_input
  end

  def separate_in_years data
    years = []
    data.each do |saldo|
      years = get_one_year_distributions saldo, years
    end
    years
  end

  def by_years(objectives)
    # objectives.map {|o| o.created_at.strftime('%Y').to_i}.sort.uniq
    objectives.group_by{|o| o.created_at.strftime('%Y')}
              .keys
              .map(&:to_i)
              .sort
  end

  def get_one_year_distributions saldo, years
    date = saldo.created_at.strftime('%Y').to_i
    unless years.include? date
      years.push(date)
    end
    years
  end

  def get_kleer_historical_years
    actual_year = FIRST_YEAR
    years = []

    while actual_year <= Time.now.year
      years.push(actual_year)
      actual_year += 1
    end
    years
  end
end
