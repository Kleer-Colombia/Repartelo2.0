# frozen_string_literal: true
require 'faker'
#TODO use faker?

Given(/^i have a user in the db$/) do
    @user_for_login=DataFactory.create_one_user
end

Given(/^i have an invalid user$/) do
  @user_for_login =User.new
  @user_for_login.name='alan brito'
  @user_for_login.email='alan@brito.com'
  @user_for_login.password='123456789'
  @user_for_login.password_confirmation='123456789'
end

When(/^i do login$/) do
  @actual_page = LoginPageObject.new page
  @actual_page = @actual_page.login @user_for_login
end

Then(/^i should see invalid user and password$/) do
  expect(@actual_page.find_error).to eq 'Invalid user or password'
end