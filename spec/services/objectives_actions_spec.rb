require 'rails_helper'

ObjectivesActions = ObjetivesActions
describe ObjectivesActions do
  before(:each) do
    @actions = ObjectivesActions.new

    @kleerers = [
      Kleerer.new(name: "Leo",
                  option: Option.new(name: 'sin_cumplir_meta', value: 10),
                  id: 1000),
      Kleerer.new(name: "Jader",
                  option: Option.new(name: 'meta', value: 10),
                  id: 1001),
      Kleerer.new(name: "Juli",
                  option: Option.new(name: 'meta_cumplida', value: 10),
                  id: 1002),
      Kleerer.new(name: "Camilo",
                  option: Option.new(name: 'meta_cumplido', value: 10),
                  id: 1003)
    ]

    @kleerCo = Kleerer.new(name:'KleerCo',
                           option: Option.new(name: 'home', value: 0),
                           id: 999)
    @kleerCo.save!
    @kleerers.each { |e| e.save! }

    balances = [
      Balance.new(project: 'project 1',
                  client: 'client',
                  description: 'description 2',
                  date: Time.parse('2021-10-21T19:54:45.808Z')),
      Balance.new(project: 'project 2',
                  client: 'client',
                  description: 'description 2',
                  date: Time.parse('2021-10-21T19:54:45.808Z')),
      Balance.new(project: 'project 3',
                  client: 'client',
                  description: 'description 3',
                  date: Time.parse('2022-10-21T19:54:45.808Z')),
      Balance.new(project: 'project 4',
                  client: 'client',
                  description: 'description 4',
                  date: Time.parse('2022-10-21T19:54:45.808Z')),
      Balance.new(project: 'project 5',
                  client: 'client',
                  description: 'description 5',
                  date: Time.parse('2024-10-21T19:54:45.808Z')),
    ]

    balances.each{|e| e.save!}

    set_kleerco_saldos(balances)
    set_aux_saldos(balances)
    set_percentages(balances)
    @objectives = set_objectives
    @complete_distribution = @actions.find_objectives_distributions
  end


  it 'Get individual contributions to kleerCo' do
    leo_contrib = @actions.get_one_kleerer_input(@kleerers[0] , @kleerCo)
    jader_contrib = @actions.get_one_kleerer_input(@kleerers[1], @kleerCo)
    juli_contrib = @actions.get_one_kleerer_input(@kleerers[2], @kleerCo)
    camilo_contrib = @actions.get_one_kleerer_input(@kleerers[3], @kleerCo)

    expect(leo_contrib[:inputs]).to eq([{ :year => 2021, :input => 2000000 },
                                        { :year => 2022, :input => 6000000}])
    expect(jader_contrib[:inputs]).to eq([{:year => 2021, :input => 5000000},
                                          {:year => 2022, :input => 4000000},
                                          {:year => 2023, :input => 2000000}])
    expect(juli_contrib[:inputs]).to eq([{:year => 2022, :input => 2000000},
                                          {:year => 2023, :input => 2000000}])
    expect(camilo_contrib[:inputs]).to eq([{:year => 2023, :input => 4000000}])
  end

  it 'Get all kleerer contributions' do
    contributions = @actions.find_kleerers_inputs(@kleerCo)
    expect(contributions).to eq([
                                  {
                                    :name => 'Leo', :hasMeta => true,
                                    :inputs => [{ :year => 2021, :input => 2000000 },
                                                { :year => 2022, :input => 6000000}]
                                  },
                                  {
                                    :name => 'Jader', :hasMeta => true,
                                    :inputs => [{:year => 2021, :input => 5000000},
                                                {:year => 2022, :input => 4000000},
                                                {:year => 2023, :input => 2000000}]
                                  },
                                  {
                                    :name => 'Juli', :hasMeta => true,
                                    :inputs => [{:year => 2022, :input => 2000000},
                                                {:year => 2023, :input => 2000000}]
                                  },
                                  {
                                    :name => 'Camilo', :hasMeta => true,
                                    :inputs => [{:year => 2023, :input => 4000000}]
                                  }
                                ])
  end

  it 'Get kleerers in 2023 objective' do
    kleerer_income_list = @actions.find_kleerers_inputs(@kleerCo)

    contributers = @actions.get_income_by_year(
      kleerer_income_list,
      @objectives[2].kleerers_objectives,
      2023
    )

    names = contributers.map{|e| e[:name]}
    expect(names).to eq(['Leo','Jader','Juli','Camilo'])
  end

  it 'Camilo should has custom objective un 2023' do
    kleerer_income_list = @actions.find_kleerers_inputs(@kleerCo)

    contributers = @actions.get_income_by_year(
      kleerer_income_list,
      @objectives[2].kleerers_objectives,
      2023
    )

    camilo = contributers.find{|e| e[:name] == 'Camilo'}

    expect(camilo[:custom_objective]).to eq(1000000)
  end

  it 'Juli should contribute 2M and have a 4M objective' do
    initial_income_list = @kleerers.map{|e|
      {
        id: e.id,
        name: e.name,
        amount: 0
      }
    }

    kleerer_income_list = @actions.find_kleerers_inputs(@kleerCo)

    contributers = @actions.get_income_by_year(
      kleerer_income_list,
      @objectives[2].kleerers_objectives,
      2023
    )

    distributed_kleerers, initial_income_list = @actions.get_objective_calcules(contributers, initial_income_list, @objectives[2])

    juli = distributed_kleerers.find{|e| e[:name] == 'Juli'}
    expect(juli[:anualMeta]).to eq(4000000)
    expect(juli[:total_income]).to eq(2000000)
  end

  it '2019 objective should be null' do
    objective2019 = @complete_distribution.find{|e| e[:year] == 2019}
    expect(objective2019).to eq(nil)
  end

  it 'Jaders initial income in 2023 should be greater than 0' do
    objective2023 = @complete_distribution.find{|e|
      e["year"] == 2023
    }

    jader = objective2023["kleerers"].find{|e| e[:name] == 'Jader'}
    expect(jader[:initial_income] > 0).to eq(true)
  end
end

def set_kleerco_saldos(balances)
  [
    Saldo.new(amount: 4000000, kleerer_id: 999,
              reference: "Referencia genérica", balance_id: balances[0].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2021-10-21T19:54:45.808Z')),
    Saldo.new(amount: 3000000, kleerer_id: 999,
              reference: "Referencia genérica", balance_id: balances[1].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2021-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: 999,
              reference: "Referencia genérica", balance_id: balances[2].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 8000000, kleerer_id: 999,
              reference: "Referencia genérica", balance_id: balances[3].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 8000000, kleerer_id: 999,
              reference: "Referencia genérica", balance_id: balances[4].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2023-10-21T19:54:45.808Z'))
  ].each {|e| e.save!}
end

def set_aux_saldos(balances)
  # 2021 - 1 - Leo - Jader
  # 2021 - 2 - Jader
  # 2022 - 1 - Jader - Leo
  # 2022 - 2 - Jader - Leo - Juli
  # 2023 - 1 - Jader - Juli - Camilo

  [
    Saldo.new(amount: 1000000, kleerer_id: @kleerers[0].id,
              reference: "Referencia genérica", balance_id: balances[0].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2021-10-21T19:54:45.808Z')),
    Saldo.new(amount: 1000000, kleerer_id: @kleerers[1].id,
              reference: "Referencia genérica", balance_id: balances[0].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2021-10-21T19:54:45.808Z')),
    Saldo.new(amount: 1000000, kleerer_id: @kleerers[1].id,
              reference: "Referencia genérica", balance_id: balances[1].id,
              concept: "concepto genérico", created_at: Time.parse('2021-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2021-10-21T19:54:45.808Z')),
    Saldo.new(amount: 1000000, kleerer_id: @kleerers[1].id,
              reference: "Referencia genérica", balance_id: balances[2].id,
              concept: "concepto genérico", created_at: Time.parse('2022-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[0].id,
              reference: "Referencia genérica", balance_id: balances[2].id,
              concept: "concepto genérico", created_at: Time.parse('2022-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[0].id,
              reference: "Referencia genérica", balance_id: balances[3].id,
              concept: "concepto genérico", created_at: Time.parse('2022-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[1].id,
              reference: "Referencia genérica", balance_id: balances[3].id,
              concept: "concepto genérico", created_at: Time.parse('2022-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[2].id,
              reference: "Referencia genérica", balance_id: balances[3].id,
              concept: "concepto genérico", created_at: Time.parse('2022-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[1].id,
              reference: "Referencia genérica", balance_id: balances[4].id,
              concept: "concepto genérico", created_at: Time.parse('2023-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2023-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[2].id,
              reference: "Referencia genérica", balance_id: balances[4].id,
              concept: "concepto genérico", created_at: Time.parse('2023-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2023-10-21T19:54:45.808Z')),
    Saldo.new(amount: 4000000, kleerer_id: @kleerers[3].id,
              reference: "Referencia genérica", balance_id: balances[4].id,
              concept: "concepto genérico", created_at: Time.parse('2023-10-21T19:54:45.808Z'),
              updated_at: Time.parse('2023-10-21T19:54:45.808Z')),
  ].each{|e| e.save!}
end

def set_percentages(balances)
  balances[0].percentages = [
    Percentage.new(value: 50, kleerer_id: @kleerers[0].id),
    Percentage.new(value: 50, kleerer_id: @kleerers[1].id)
  ]

  balances[1].percentages = [
    Percentage.new(value: 100, kleerer_id: @kleerers[1].id),
  ]

  balances[2].percentages = [
    Percentage.new(value: 50, kleerer_id: @kleerers[1].id),
    Percentage.new(value: 50, kleerer_id: @kleerers[0].id),
  ]

  balances[3].percentages = [
    Percentage.new(value: 50, kleerer_id: @kleerers[0].id),
    Percentage.new(value: 25, kleerer_id: @kleerers[1].id),
    Percentage.new(value: 25, kleerer_id: @kleerers[2].id),
  ]

  balances[4].percentages = [
    Percentage.new(value: 25, kleerer_id: @kleerers[1].id),
    Percentage.new(value: 25, kleerer_id: @kleerers[2].id),
    Percentage.new(value: 50, kleerer_id: @kleerers[3].id),
  ]

  balances.each { |e| e.save! }
end

def set_objectives
  objectives = [
    Objective.new(amount: 5000000, initial_balance_percentage: 0,
                  created_at: Time.parse('2021-10-21T19:54:45.808Z'),
                  updated_at: Time.parse('2021-10-21T19:54:45.808Z')),
    Objective.new(amount: 3000000, initial_balance_percentage: 50,
                  created_at: Time.parse('2022-10-21T19:54:45.808Z'),
                  updated_at: Time.parse('2022-10-21T19:54:45.808Z')),
    Objective.new(amount: 12000000, initial_balance_percentage: 50,
                  created_at: Time.parse('2023-10-21T19:54:45.808Z'),
                  updated_at: Time.parse('2023-10-21T19:54:45.808Z'))
  ]

  objectives[0].kleerers_objectives = [
    KleerersObjective.new(kleerer_id: @kleerers[1].id, has_custom_objective: false),
  ]

  objectives[1].kleerers_objectives = [
    KleerersObjective.new(kleerer_id: @kleerers[1].id, has_custom_objective: false),
    KleerersObjective.new(kleerer_id: @kleerers[0].id, has_custom_objective: false),
    KleerersObjective.new(kleerer_id: @kleerers[2].id, has_custom_objective: true, objective_amount: 1000000),
  ]

  objectives[2].kleerers_objectives = [
    KleerersObjective.new(kleerer_id: @kleerers[0].id, has_custom_objective: false),
    KleerersObjective.new(kleerer_id: @kleerers[1].id, has_custom_objective: false),
    KleerersObjective.new(kleerer_id: @kleerers[2].id, has_custom_objective: false),
    KleerersObjective.new(kleerer_id: @kleerers[3].id, has_custom_objective: true, objective_amount: 1000000),
  ]

  objectives.each{|e| e.save!}
end
