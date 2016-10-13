$:.push(File.join(Gem.loaded_specs['txgh'].full_gem_path, 'spec'))
$:.push(File.join(Gem.loaded_specs['txgh-queue'].full_gem_path, 'spec'))

require 'pry-byebug'
require 'rake'
require 'rspec'
require 'txgh-server'
require 'txgh-queue'
require 'vcr'
require 'webmock'
require 'yaml'

require 'helpers/test_events'
require 'helpers/test_backend'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding(integration: true) unless ENV['FULL_SPEC']

  config.before(:each) do
    Txgh.instance_variable_set(:@events, TestEvents.new)
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/integration/cassettes'
  config.hook_into :webmock
end

TxghQueue::Backends.register('test', TxghQueue::TestBackend)
