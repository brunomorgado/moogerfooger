require "bundler/setup"
require "moogerfooger"
require 'fakefs/safe'
require 'pp'
require 'rspec'
require 'pry'
require 'helpers/git_helpers'
require 'builders/builder'

SPECS_ROOT = __dir__

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include(GitHelpers)
  config.include(Builder)
end
