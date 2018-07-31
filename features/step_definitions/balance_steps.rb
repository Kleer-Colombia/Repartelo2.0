# frozen_string_literal: true
And(/^I have kleerers$/) do
  DataFactory.create_kleerers
end

Given(/^I logged$/) do
  DataFactory.clean_balances
  step 'i have a user in the db'
  step 'i do login'
end

When(/^I create a new standard balance for client "([^"]*)"$/) do |client|
  @actual_page = @actual_page.new_balance
  if client != ''
    @actual_page.create_balance client: client, project: 'PAS',
                                description: 'balance de prueba', date: Time.new(2017, 11, 23), type: :standard
  end
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

When(/^I calculate the balances with "([^"]*)" as a kleerer$/) do |kleerer|
  @actual_page.calculate_balance kleerer
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
  expect(@actual_page.find_error).to eq 'Error: 500:Nothing to distribute!'
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
                :output => {:KleerCo =>{ingresos: "$30.300,00", egresos: '0',total: '$30.300,00'},
                            :Full => {ingresos: "$69.700,00", egresos: '0',total: "$69.700,00"}} },
                3 => {:input =>[{:client => 'sparkta',:income => '100000.00',:kleerer => :Socio},
                                  {:client => 'SAP corp',:income => '100000.00',:kleerer => :Socio},
                                  {:client => 'mi banco',:income => '100000.00',:kleerer => :Socio}],
                :output => {:KleerCo =>{ingresos: "$66.300,00", egresos: '0',total: '$66.300,00'},
                            :Socio => {ingresos: "$233.700,00", egresos: '0',total: "$233.700,00"}} }
               }

And(/^I have (\d+) distributed balances$/) do |quantity_of_balances|

  @balances_data = BALANCE_DATA[quantity_of_balances]
  @balances_data[:input].each do |balance|
    step 'I create a new standard balance for client "'+balance[:client]+'"'
    step 'I add income for "'+balance[:income]+'"'
    step 'I calculate the balances with "' + balance[:kleerer].to_s+'" as a kleerer'
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
  expect(@actual_page.editable? 'Enviar a saldos').to eq false
  expect(@actual_page.editable? 'Enviar a saldos').to eq false
  Kleerer.all.each do |kleerer|
    unless kleerer.name == "KleerCo"
      expect(@actual_page.editable?("check#{kleerer.name}")).to eq false
    end
  end

end