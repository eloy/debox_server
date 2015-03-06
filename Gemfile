source 'https://rubygems.org'

gem 'rack'
gem 'grape'
gem 'thin'
gem 'json'
gem 'capistrano', '~>2.15.5'
gem 'redis'
gem 'log4r'


group :development, :test do
  gem 'mysql2'
end

group :development do
  gem 'pry'
end

group :test do
  gem 'rspec', '~> 2.13.0'
  gem 'rack-test'
  gem 'factory_girl'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
end

# Specify your gem's dependencies in debox_server.gemspec
gemspec
