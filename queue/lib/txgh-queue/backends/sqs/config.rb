module TxghQueue
  module Backends
    module Sqs
      class Config
        class << self
          def queues
            @queues ||= TxghQueue::Config.options[:queues].map do |queue_options|
              Queue.new(queue_options)
            end
          end

          def failure_queue
            @failure_queue ||= Queue.new(
              TxghQueue::Config.options[:failure_queue]
            )
          end

          def get_queue(queue_name)
            queues.find { |q| q.name == queue_name }
          end

          def reset!
            @queues = nil
          end
        end
      end
    end
  end
end
