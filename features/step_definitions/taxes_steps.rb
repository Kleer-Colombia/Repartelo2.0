And(/^I have taxes$/) do
  DataFactory.create_taxes
end

And(/^I have data for taxes$/) do
  DataFactory.load_taxes
end

Then(/^I should see the Impuestos home page$/) do
  pending
end

And(/^I see the data for all taxes$/) do
  pending
end