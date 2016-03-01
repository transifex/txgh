module Txgh
  module Handlers
    class Response
      attr_reader :status, :body

      def initialize(status, body)
        @status = status
        @body = body
      end
    end
  end
end
