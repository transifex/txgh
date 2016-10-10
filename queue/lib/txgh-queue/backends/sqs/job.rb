require 'json'

module TxghQueue
  module Backends
    module Sqs
      class Job < TxghQueue::Job
        attr_reader :message, :message_attributes, :queue, :logger

        def initialize(message, queue, logger)
          @message = message
          @queue = queue
          @message_attributes = MessageAttributes.from_message(message)

          # add empty retry attributes hash to sequence - will be populated when
          # the complete method is called
          message_attributes.history_sequence.add({})

          super(logger)
        end

        def complete
          result = process(payload)
          logger.info("Finished processing #{message.message_id}, result: #{result.status}")

          message_attributes.history_sequence.current.merge!(attributes_for(result))

          return do_ok(result) if result.status.ok?
          return do_retry(result) if result.status.retry?
          return do_fail(result) if result.status.fail?
        end

        private

        def attributes_for(result)
          { status: result.status.to_s }.merge(
            if result.has_error?
              error_attributes_for(result)
            else
              response_attributes_for(result)
            end
          )
        end

        def error_attributes_for(result)
          {
            response_type: 'error',
            class: result.error.class,
            message: result.error.message,
            backtrace: (result.error.backtrace || []).first,
            error_tracking: publish_error_for(result)
          }
        end

        def response_attributes_for(result)
          {
            response_type: 'response',
            code: result.response.status,
            body: result.response.body
          }
        end

        def payload
          @payload ||= begin
            logger.info("Processing #{message.message_id}")

            JSON.parse(message.body).tap do |payload|
              logger.info("Payload: #{payload.inspect}")
            end
          end
        end

        def do_ok(result)
          delete(message)
          logger.info("Deleted #{message.message_id}")
        end

        def do_retry(result)
          retry_logic = RetryLogic.new(message_attributes, result.status)

          if retry_logic.retry?
            logger.info("Retrying #{message.message_id} with #{retry_logic.next_delay_seconds} second delay")
            new_message = queue.send_message(message.body, retry_logic.sqs_retry_params)
            logger.info("Re-enqueued as #{new_message.message_id}")
            delete(message)
            logger.info("Deleted original #{message.message_id}")
          elsif retry_logic.retries_exceeded?
            logger.info("Message #{message.message_id} has exceeded allowed retries.")
            do_fail(result)
          end
        end

        def do_fail(result)
          # send to failure queue
          new_message = Config.failure_queue.send_message(
            message.body, message_attributes: message_attributes.to_h
          )

          delete(message)
        end

        def publish_error_for(result)
          Txgh.events.publish_error(result.error, {
            payload: payload,
            message_id: message.message_id,
            queue: queue.name
          })
        end

        def delete(message)
          queue.delete_message(message.receipt_handle)
        end
      end
    end
  end
end
