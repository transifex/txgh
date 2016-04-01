module Txgh
  module Handlers
    class Response
      attr_reader :status, :body, :error

      def initialize(status, body, error = nil)
        @status = status
        @body = body
        @error = error
      end

      def streaming?
        false
      end
    end
  end
end
