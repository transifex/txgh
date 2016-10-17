require 'txgh-server'

module TxghQueue
  module ErrorHandlers
    class ServerResponse
      class << self
        def can_handle?(error_or_response)
          error_or_response.is_a?(TxghServer::Response)
        end

        def status_for(response)
          case response.status.to_i / 100
            when 2, 3
              Status.ok
            else
              Status.fail
          end
        end
      end
    end
  end
end
