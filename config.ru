# frozen_string_literal: true

# require "bundler"
# Bundler.require(:default, ENV["RACK_ENV"].to_sym)

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "./app"
run App
# run Sinatra::Application

# starting thin server
# thin -C config/development.yml -R config.ru start
# thin start -p 55710 -d -e production --tag ASV_SERVICE


