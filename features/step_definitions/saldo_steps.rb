Then(/^I should see the saldos home page$/) do
  expect(@actual_page.find_title).to eq 'Saldos Kleerers'
end

And(/^I see the data for all kleerers$/) do
  Kleerer.all.each do |kleerer|
    expect(@actual_page.has_kleerer? kleerer.name).to eq true
  end
end

And(/^I see the money distribution for all of them$/) do
  @balances_data[:output].each_key do |kleerer|
    @actual_page.select_kleerer kleerer
      expect(@actual_page.find_total).to eq @balances_data[:output][kleerer][:total]
      expect(@actual_page.find_ingresos).to eq @balances_data[:output][kleerer][:ingresos]
      expect(@actual_page.find_egresos).to eq @balances_data[:output][kleerer][:egresos]
  end
end
