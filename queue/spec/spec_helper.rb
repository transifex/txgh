require 'pry-byebug'
require 'rake'
require 'rspec'
require 'txgh-queue'
require 'txgh-server'

require 'spec_helpers/env_helpers'
require 'spec_helpers/nil_logger'
require 'spec_helpers/test_backend'

RSpec.configure do |config|
  module GlobalLets
    extend RSpec::SharedContext

    # default config, override in specs if you wanna customize
    let(:queue_config) do
      {
        backend: 'test',
        options: {
          queues: %w(test-queue)
        }
      }
    end
  end

  config.include(GlobalLets)
  config.include(EnvHelpers)

  config.around(:each) do |example|
    if example.metadata[:auto_configure]
      env_vars = { 'TXGH_QUEUE_CONFIG' => "raw://#{YAML.dump(queue_config)}" }
      with_env(env_vars) { example.run }

      # reset global config
      TxghQueue::Config.reset!
    else
      example.run
    end
  end
end

TxghQueue::Backends.register('test', TxghQueue::TestBackend)
