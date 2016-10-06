module TxghQueue
  module ErrorHandlers
    class StandardErrors
      class << self
        def can_handle?(error_or_response)
          error_or_response.is_a?(StandardError)
        end

        def status_for(response)
          Status.fail
        end
      end
    end
  end
end
