source 'https://rubygems.org'

# the framework
gem 'sinatra'

# for layout
gem 'haml'
gem 'sass'
gem 'coffee-script'
gem 'multi_json'

if RUBY_PLATFORM =~ /linux/
  gem 'execjs'
  gem 'therubyracer', platforms: :ruby
end 

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

# server
gem 'thin'