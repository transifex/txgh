require 'json'
require 'txgh'

module TxghQueue
  module Backends
    module Sqs
      class Consumer
        RECEIVE_PARAMS = { message_attribute_names: %w(history_sequence) }

        attr_reader :queues, :logger

        def initialize(queues, logger)
          @queues = queues
          @logger = logger
        end

        def work
          queues.each do |queue|
            queue.receive_message(RECEIVE_PARAMS).messages.each do |message|
              logger.info("Received message from #{queue.name}, id: #{message.message_id}")
              Job.new(message, queue, logger).complete
            end
          end
        rescue => e
          Txgh.events.publish_error!(e)
        end
      end
    end
  end
end
