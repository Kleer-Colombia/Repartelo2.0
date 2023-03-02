class ObjetivesActions

  FIRST_YEAR = 2018

  def find_objectives_distributions
    distributed_objectives = []
    available_years = get_kleer_historical_years

    available_years.each do |year|
      objectives = Objective.where('extract(year from created_at) = ?', year)
      current_objective = objectives.max_by{|e| e.created_at}
      kleerers = current_objective ? current_objective.kleerers : []

      #hallar ingresos por kleerer
      #hallar hallar calculos

      distributed_objectives.push(year => {"amount" => current_objective ? current_objective.amount : 0,
                                           "kleerers" => kleerers
      })

    end

    puts distributed_objectives
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


  def add_objective objective
    objective = Objective.new(amount: objective[:amount], initial_balance_percentage: objective[:percentage])
    objective.save!
  end

  def add_kleerer_to_objective(kleerer_id, objective_id)
    kleerer = Kleerer.find(kleerer_id)
    objective = Objective.find(objective_id)

    objective.kleerers.push(kleerer)
    objective.save!
  end

  # private

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
