require 'txgh-server'

module TxghQueue
  module Webhooks
    module Transifex
      class RequestHandler < ::TxghServer::Webhooks::Transifex::RequestHandler
        TXGH_EVENT = 'transifex.hook'

        def handle_request
          handle_safely do
            result = ::TxghQueue::Config.backend
              .producer_for(TXGH_EVENT, logger)
              .enqueue(payload.merge(txgh_event: TXGH_EVENT))

            respond_with(202, result.to_json)
          end
        end
      end
    end
  end
end
