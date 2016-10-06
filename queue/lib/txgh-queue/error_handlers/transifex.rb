require 'txgh'

module TxghQueue
  module ErrorHandlers
    class Transifex
      ERROR_CLASSES = {
        Txgh::TransifexApiError          => Status.retry_with_delay,
        Txgh::TransifexNotFoundError     => Status.fail,
        Txgh::TransifexUnauthorizedError => Status.fail
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
