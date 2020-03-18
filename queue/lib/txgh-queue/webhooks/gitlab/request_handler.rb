require 'txgh-server'

module TxghQueue
  module Webhooks
    module Gitlab
      class RequestHandler < ::TxghServer::Webhooks::Gitlab::RequestHandler
        def handle_request
          handle_safely do
            case gitlab_event
              when 'push', 'delete'
                txgh_event = "github.#{gitlab_event}"

                result = ::TxghQueue::Config.backend
                  .producer_for(txgh_event, logger)
                  .enqueue(attributes.to_h.merge(txgh_event: txgh_event))

                respond_with(202, result.to_json)
              when 'ping'
                ping_handler.execute
              else
                respond_with_error(400, "Event '#{gitlab_event}' cannot be enqueued")
            end
          end
        end

        private

        def ping_handler
          @ping_handler ||= TxghServer::Webhooks::Gitlab::PingHandler.new(logger)
        end
      end
    end
  end
end
