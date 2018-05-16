When(/^I go to the "([^"]*)" option$/) do |option|
  @actual_page = @actual_page.go_for option
end