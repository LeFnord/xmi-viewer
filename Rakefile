# frozen_string_literal: true

require "./app"
require "rspec/core/rake_task"

# require "./lib/rxmi"

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: %i[spec rubocop]
