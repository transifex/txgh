module TxghQueue
  class Result
    attr_reader :status, :response_or_error

    def initialize(status, response_or_error)
      @status = status
      @response_or_error = response_or_error
    end

    def has_response?
      response_or_error.is_a?(TxghServer::Response)
    end

    def response
      return response_or_error if has_response?
    end

    def has_error?
      response_or_error.is_a?(Exception)
    end

    def error
      return response_or_error if has_error?
    end
  end
end
