# frozen_string_literal: true

source 'https://rubygems.org'

# the framework
gem 'sinatra'

# for layout
gem 'haml'
gem 'sass'
gem 'coffee-script'
gem 'multi_json'

# server
gem 'thin'

group :development do
  gem 'rake'
  gem 'sinatra-reloader'
  gem 'awesome_print'
end

group :test do
  gem "rspec"
  gem "guard"
  gem "guard-rspec"
  gem "guard-bundler"
  gem "terminal-notifier-guard"
end

group :development, :test do
  gem "rubocop"
end
