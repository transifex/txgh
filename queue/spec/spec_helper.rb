require 'pry-byebug'
require 'rake'
require 'rspec'
require 'txgh-queue'
require 'txgh-server'

require 'helpers/env_helpers'
require 'helpers/nil_logger'
require 'helpers/test_backend'

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

    # default sqs config; override queue_config with this when working with the
    # sqs backend, i.e. let(:queue_config) { sqs_queue_config }
    let(:sqs_queue_config) do
      {
        backend: 'sqs',
        options: {
          queues: [
            { name: 'test-queue', region: 'us-east-1', events: %w(a b c) },
            { name: 'test-queue-2', region: 'us-west-1', events: %w(c d e) }
          ],

          failure_queue: {
            name: 'test-failure-queue', region: 'us-east-1'
          }
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
      TxghQueue::Backends::Sqs::Config.reset!
    else
      example.run
    end
  end
end

TxghQueue::Backends.register('test', TxghQueue::TestBackend)
