And(/^I have taxes$/) do
  DataFactory.create_taxes
end

And(/^I have data for taxes$/) do
  DataFactory.load_balances
  DataFactory.load_taxes
end

Then(/^I should see the Impuestos home page$/) do
  expect(@actual_page.find_title).to eq 'Impuestos'
end

And(/^I see the data for all taxes$/) do
  expect(@actual_page.find_total_for('Ica')).to eq '$3.231.133,76'
  expect(@actual_page.find_total_for('Chanchito')).to eq '$7.343.485,80'
  expect(@actual_page.find_total_for('Retefuente')).to eq '$69.783.409,79'
  expect(@actual_page.find_total_for('IVA')).to eq '$48.287.902,82'
end