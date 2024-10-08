# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require "selenium-webdriver"
require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'

module Phantomjs
  class Platform
    class << self
      def system_phantomjs_path
        nil
      end
    end

    class Win32x86_64 < Win32
      class << self
        def useable?
          host_os.include?('mingw32') and architecture.include?('x86_64')
        end
      end
    end
  end
end

Phantomjs.available_platforms << Phantomjs::Platform::Win32x86_64

def poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
        js_errors: true,
        phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'],
        debug: false,
        timeout: 500,
        window_size:[1440,900],
        phantomjs: File.absolute_path(Phantomjs.path)
    })
  end
  Capybara.javascript_driver = :poltergeist
  Capybara.default_max_wait_time = 5

end

def chrome
  driver_class = Selenium::WebDriver
  capabilities = driver_class::Remote::Capabilities.chrome
  options      = driver_class::Chrome::Options.new(args: %w{start-maximized log-level=3})

  Capybara.register_driver :chrome do |app|
    driver_options = {
      browser: :chrome,
      capabilities: [capabilities, options]
    }

    Capybara::Selenium::Driver.new(app, driver_options)
  end

  Capybara.javascript_driver = :chrome
end

def headless_chrome
  driver_class = Selenium::WebDriver
  capabilities = driver_class::Remote::Capabilities.chrome
  options      = driver_class::Chrome::Options.new(args: %w{headless disable-gpu start-maximized log-level=3})

  Capybara.register_driver(:headless_chrome) do |app|
    driver_options = {
      browser: :chrome,
      capabilities: [capabilities, options]
    }

    Capybara::Selenium::Driver.new(app, driver_options)
  end

  Capybara.javascript_driver = :headless_chrome
end

# TODO adjust this for browser validation

if(ENV['RAILS_ENV']=='acceptance_test')
  caps = Selenium::WebDriver::Remote::Capabilities.firefox
  Capybara.default_driver = :selenium
  Capybara.default_max_wait_time = 5
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote,
                                   :url => "http://localhost:4444/wd/hub",
                                   :capabilities => caps)
  end
else
  if ENV['BROWSER'] == 'headless-chrome'
    headless_chrome
  else
    #poltergeist
    chrome
  end
end

Capybara.server = :puma, { Silent: true }

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { except: [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('not @no-txn', 'not @selenium', 'not @culerity', 'not @celerity', 'not @javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation
