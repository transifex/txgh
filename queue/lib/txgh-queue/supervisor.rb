require 'txgh'

module TxghQueue
  class UnexpectedResponse < StandardError; end

  class Supervisor
    # ErrorHandlers::StandardErrors should always come last as a catch-all for
    # unexpected errors. All errors handled by this supervisor inherit from
    # StandardError, so putting it too early in the handler list may cause an
    # error to be mis-handled.
    ERROR_HANDLERS = [
      ErrorHandlers::ServerResponse,
      ErrorHandlers::Github,
      ErrorHandlers::Transifex,
      ErrorHandlers::TxghErrors,
      ErrorHandlers::StandardErrors
    ]

    class << self
      def supervise(&block)
        new(&block).execute
      end
    end

    attr_reader :block

    def initialize(&block)
      @block = block
    end

    def execute
      response = block.call
    rescue StandardError => e
      status = status_for_error(e)
      Result.new(status, e)
    else
      status = status_for_response(response)
      Result.new(status, response)
    end

    private

    def status_for_response(response)
      klass = find_error_handler_class_for(response)

      unless klass
        message = unexpected_response_error_message(response)
        raise UnexpectedResponse, message
      end

      klass.status_for(response)
    end

    def unexpected_response_error_message(response)
      return response unless response.respond_to?(:status)
      return response unless response.respond_to?(:body)
      "#{response.status} #{response.body}"
    end

    def status_for_error(error)
      # Don't bother handling the case where find_behavior_class returns nil
      # since it will realistically never occur. The execute method above
      # rescues all StandardErrors, which will always be matched by
      # ErrorBehavior::StandardErrors. In cases where errors that don't inherit
      # from StandardError are raised, execute won't catch them and therefore
      # won't call this method.
      find_error_handler_class_for(error).status_for(error)
    end

    def find_error_handler_class_for(response_or_error)
      ERROR_HANDLERS.find do |klass|
        klass.can_handle?(response_or_error)
      end
    end
  end
end
