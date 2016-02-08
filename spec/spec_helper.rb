# encoding: UTF-8

require 'pry-nav'
require 'rake'
require 'rspec'
require 'txgh'
require 'vcr'
require 'webmock'
require 'yaml'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding(integration: true) unless ENV['FULL_SPEC']
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/integration/cassettes'
  config.hook_into :webmock
end
