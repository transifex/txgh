require 'json'

module TxghQueue
  module Backends
    module Sqs
      class Producer
        attr_reader :queues, :logger

        def initialize(queues, logger)
          @queues = queues
          @logger = logger
        end

        def enqueue(payload, options = {})
          payload_json = payload.to_json

          message_ids = queues.map do |queue|
            new_message = queue.send_message(payload_json, options)

            logger.info(
              "Enqueued new message with id #{new_message.message_id} and params "\
                "#{payload_json}"
            )

            new_message.message_id
          end

          { message_ids: message_ids }
        end
      end
    end
  end
end
