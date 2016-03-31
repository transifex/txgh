module Txgh
  module Handlers
    class Response
      attr_reader :status, :body

      def initialize(status, body)
        @status = status
        @body = body
      end

      def streaming?
        false
      end
    end
  end
end
