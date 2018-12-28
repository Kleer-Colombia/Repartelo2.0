# frozen_string_literal: true
And(/^I have kleerers$/) do
  DataFactory.create_kleerers
end

And(/^I have Taxes$/) do
  DataFactory.create_taxes
end

Given(/^I logged$/) do
  DataFactory.clean_balances
  step 'i have a user in the db'
  step 'i do login'
end

When(/^I create a new standard balance for client "([^"]*)"$/) do |client|
  create_balance client: client, project: 'PAS',
                 description: 'balance de prueba', date: Time.new(2017, 11, 23),
                 type: 'standard'
end


When(/^I create a new coaching balance for client "([^"]*)"$/) do |client|
  create_balance client: client, project: 'PAS',
                 description: 'balance de prueba', date: Time.new(2017, 11, 23),
                 type: 'coaching'
end

def create_balance params
  @actual_page = @actual_page.new_balance
  @actual_page.create_balance params if params[:client] != ''
  @actual_page = @actual_page.save_balance
end

Then(/^i should see the balances homepage$/) do
  expect(@actual_page.find_title).to eq 'Módulo de Balances'
end

Then(/^I should the principal page for the balance$/) do
  expect(@actual_page.find_client).to eq 'Sparkta'
  expect(@actual_page.find_project).to eq 'PAS'
  expect(@actual_page.find_date).to eq '2017-11-23'
  expect(@actual_page.find_description).to eq 'balance de prueba'
end

And(/^I should have an option to admin coaching sessions$/) do
  expect(@actual_page.coaching_balance?).to eq true
end

Then(/^I should the an error message$/) do
  expect(@actual_page.find_error).to eq 'Error: 500:Invalid parameters creating balance invalid date'
end

When(/^I add income for "([^"]*)"$/) do |income|
  @actual_page.add_income income
end

When(/^I add expense for "([^"]*)"$/) do |expense|
  @actual_page.add_expense expense
end

When(/^I remove income for "([^"]*)"$/) do |income|
  @actual_page.remove_income income
end

When(/^I remove expense for "([^"]*)"$/) do |expense|
  @actual_page.remove_expense expense
end

Then(/^I should see "([^"]*)" for total "([^"]*)"$/) do |total, operation|
  real_value = if operation == 'expenses'
    @actual_page.find_total_expenses
  elsif operation == 'incomes'
    @actual_page.find_total_incomes
  else
    @actual_page.find_total_profit
               end
  expect(real_value).to eq total
end

When(/^I select "([^"]*)" as a kleerer$/) do |kleerer|
  @actual_page.select_kleerer kleerer
end

And(/^the percentage for "([^"]*)" is "([^"]*)"$/) do |kleerer, amount|
  @actual_page.set_percentage kleerer,amount
end

When(/^I distribute the profit$/) do
  @actual_page.distribute
end

Then(/^I should see "([^"]*)" for "([^"]*)"$/) do |money, kleerer|
  expect(@actual_page.find_amount_to(kleerer)).to eq money
end


Then(/^I should the an invalid profit distribution error$/) do
  expect(@actual_page.find_error).to eq 'Error: 406:error on distribution balance: Nothing to distribute!'
end

Then(/^I should see the balances table$/) do
  @balances.each do |balance|
    expect(@actual_page.find_balance_date(balance.id)).to eq balance.date
    expect(@actual_page.find_balance_client(balance.id)).to eq balance.client
    expect(@actual_page.find_balance_description(balance.id)).to eq balance.description
  end
end

And(/^I have (\d+) balances in the db$/) do |balances|
  @balances=DataFactory.create_balances @balances_amount
end


And(/^I don't have any balance$/) do
  DataFactory.clean_balances
end

When(/^I delete the balance$/) do
  @actual_page.delete_balance
end

When(/^I close the balance$/) do
   @actual_page.send_to_saldos
end

And(/^Confirm the elimination$/) do
  @actual_page = @actual_page.confirm_delete_balance
end

Then(/^I should the Balance home page empty$/) do
  expect(@actual_page.balance_table_is_empty?).to eq true
end



BALANCE_DATA = {1 => {:input =>[{:client => 'sparkta',:income => '100000.00',:kleerer => :Full}],
                :output => {:KleerCo =>{ingresos: "$28.600,00", egresos: '0',total: '$28.600,00'},
                            :Full => {ingresos: "$71.400,00", egresos: '0',total: "$71.400,00"}} },
                3 => {:input =>[{:client => 'sparkta',:income => '100000.00',:kleerer => :Socio},
                                  {:client => 'SAP corp',:income => '100000.00',:kleerer => :Socio},
                                  {:client => 'mi banco',:income => '100000.00',:kleerer => :Socio}],
                :output => {:KleerCo =>{ingresos: "$60.600,00", egresos: '0',total: '$60.600,00'},
                            :Socio => {ingresos: "$239.400,00", egresos: '0',total: "$239.400,00"}} }
               }

And(/^I have (\d+) distributed balances$/) do |quantity_of_balances|

  @balances_data = BALANCE_DATA[quantity_of_balances]
  @balances_data[:input].each do |balance|
    step 'I create a new standard balance for client "'+balance[:client]+'"'
    step 'I add income for "'+balance[:income]+'"'
    step 'I select "' + balance[:kleerer].to_s+'" as a kleerer'
    step 'I distribute the profit'
    step 'I close the balance'

    if quantity_of_balances != 1
      @actual_page = @actual_page.go_for('Balances')
    end

  end
end

When(/^I have (\d+) distributed coaching balance$/) do |quantity_of_balances|
  @balances_data = BALANCE_DATA[quantity_of_balances]
  @balances_data[:input].each do |balance|
    step 'I create a new coaching balance for client "'+balance[:client]+'"'
    step 'I add income for "'+balance[:income]+'"'
    step('I open the coaching sessions admin')
    step('I add a new session with "description" and the kleerers "' + balance[:kleerer].to_s + '"')
    step('I close the coaching sessions admin')
    step 'I distribute the profit'
    step 'I close the balance'

    if quantity_of_balances != 1
      @actual_page = @actual_page.go_for('Balances')
    end
  end
end

Then(/^I could not edit the balance$/) do
  expect(@actual_page.editable? 'nuevo ingreso').to eq false
  expect(@actual_page.editable? 'nuevo egreso').to eq false
  expect(@actual_page.editable? 'Distribuir').to eq false
  expect(@actual_page.editable? 'Borrar').to eq false
  expect(@actual_page.editable? 'Enviar a saldos').to eq false
  Kleerer.all.each do |kleerer|
    unless kleerer.name == "KleerCo"
      expect(@actual_page.editable?("check#{kleerer.name}")).to eq false
    end
  end
end

Then(/^I could not edit the coaching balance$/) do
  expect(@actual_page.editable? 'nuevo ingreso').to eq false
  expect(@actual_page.editable? 'nuevo egreso').to eq false
  expect(@actual_page.editable? 'Distribuir').to eq false
  expect(@actual_page.editable? 'Borrar').to eq false
  expect(@actual_page.editable? 'Enviar a saldos').to eq false
  @actual_page = @actual_page.open_coaching_sessions_admin
  expect(@actual_page.editable? 'newCoachingSession').to eq false
  expect(@actual_page.editable?('eliminar')).to eq false
end



When(/^I open the coaching sessions admin$/) do
  @actual_page = @actual_page.open_coaching_sessions_admin
end


And(/^I add a new session with "([^"]*)" and the kleerers "([^"]*)"$/) do |description, kleerers|
  @actual_page.new_coaching_session
  @actual_page.fill_coaching_session description, kleerers.split(",")
  @actual_page.create_coaching_session
end

And(/^I delete the (\d+) session$/) do |session_number|
  @actual_page.delete_coaching_session(session_number)
end

Then(/^I should see the coaching session table with (\d+) registry$/) do |numberOfRegisters|
  expect(@actual_page.count_sessions).to eq numberOfRegisters
end


And(/^I should the coaching sessions summary$/) do |data|
  data.hashes.each do |row|
    expect(@actual_page.find_summary_sessions(row[:kleerer])).to eq row[:sessions]
    expect(@actual_page.find_summary_percentage(row[:kleerer])).to eq "#{row[:percentage]}%"
  end
end


And(/^I add many new sessions$/) do |table|
  # table is a table.hashes.keys # => [:description, :kleerers]
  table.hashes.each do |row|
    step('I add a new session with "' + row[:description] + '" and the kleerers "'+ row[:kleerers] + '"')
  end
end


When(/^I select de edit option$/) do
  @actual_page = @actual_page.edit_balance
end

And(/^I close the coaching sessions admin$/) do
  @actual_page = @actual_page.close
end