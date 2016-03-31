# encoding: UTF-8

require 'pry-byebug'
require 'rake'
require 'rspec'
require 'txgh'
require 'vcr'
require 'webmock'
require 'yaml'

module SpecHelpers
  def outdent(str)
    # The special YAML pipe operator treats the text that follows as literal,
    # and includes newlines, tabs, and spaces. It also strips leading tabs and
    # spaces. This means you can include a fully indented bit of, say, source
    # code in your source code, and it will give you back a string with all the
    # indentation preserved (but without any leading indentation).
    YAML.load("|#{str}")
  end
end

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding(integration: true) unless ENV['FULL_SPEC']
  config.include(SpecHelpers)
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/integration/cassettes'
  config.hook_into :webmock
end
