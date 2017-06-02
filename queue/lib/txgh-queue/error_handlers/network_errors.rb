require 'txgh'
require 'faraday'
require 'net/protocol'

module TxghQueue
  module ErrorHandlers
    class NetworkErrors
      ERROR_CLASSES = {
        Faraday::ConnectionFailed => Status.retry_with_delay,
        Faraday::TimeoutError     => Status.retry_with_delay,
        Net::OpenTimeout          => Status.retry_with_delay,
        Net::ReadTimeout          => Status.retry_with_delay
      }

      class << self
        def can_handle?(error_or_response)
          ERROR_CLASSES.any? { |klass, _| error_or_response.class <= klass }
        end

        def status_for(error)
          ERROR_CLASSES[error.class]
        end
      end
    end
  end
end
