source 'https://rubygems.org'

ruby '2.7.7'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.19.0.beta'

#Old repositories
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
gem 'bcrypt', git: 'https://github.com/codahale/bcrypt-ruby.git', :require => 'bcrypt'

gem 'puma', '3.12.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 5.x'
gem 'foreman', '~> 0.64.0'
gem 'coffee-rails', '~> 4.2'
gem 'wdm', '>= 0.1.0' if Gem.win_platform?
# Use ActiveModel has_secure_password
#gem 'bcrypt', '~> 3.1.7' --- now in old repositories
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
gem 'money-rails'
gem 'jwt'
# ActiveAdmin
gem 'devise'
gem 'activeadmin'
gem 'faraday', '~> 0.15.4'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem "pry-rails"
  gem "pry-byebug"
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'cucumber-rails', require: false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'faker'
  gem 'rspec-rails', '~> 3.7.1'
  gem 'phantomjs'
  gem 'poltergeist'
  gem 'figaro', '~> 1.1', '>= 1.1.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
