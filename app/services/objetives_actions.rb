class ObjetivesActions

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

  def find_objectives kleerer_id
    all_objectives = Objective.where(kleerer_id: kleerer_id)
    years = separate_in_years all_objectives
    objectives = []
    puts all_objectives.max_by{|h| h[:created_at]}.id
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
      puts year
      puts year_objectives
    end
    objectives
  end

  def add_objective objective, kleerer_id
    # objective = objective[:objective]
    puts 'objective'
    puts objective
    objective = Objective.new(amount: objective[:amount], kleerer_id: kleerer_id)
    objective.save!
  end

  private

  def get_one_kleerer_input kleerer, kleerCo
    complete_kleerer_input = {
      name: kleerer.name,
      hasMeta: kleerer.option.name.include?("meta"),
      inputs: []
    }

    saldos = Saldo.where(kleerer_id: kleerer.id)
    puts "#{kleerer.id} #{kleerer.name}"

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

  def get_one_year_distributions saldo, years
    date = saldo.created_at.strftime('%Y').to_i
    unless years.include? date
      years.push(date)
    end
    years
  end

end
