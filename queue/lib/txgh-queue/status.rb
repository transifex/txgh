module TxghQueue
  class Status
    class << self
      def retry_without_delay
        @retry ||= new(status: :retry_without_delay)
      end

      def retry_with_delay
        @retry_with_delay ||= new(status: :retry_with_delay)
      end

      def fail
        @fail ||= new(status: :fail)
      end

      def ok
        @ok ||= new(status: :ok)
      end
    end

    attr_reader :status

    def initialize(options = {})
      @status = options.fetch(:status)
    end

    def retry?
      retry_with_delay? || retry_without_delay?
    end

    def retry_with_delay?
      status == :retry_with_delay
    end

    def retry_without_delay?
      status == :retry_without_delay
    end

    def fail?
      status == :fail
    end

    def ok?
      status == :ok
    end

    def to_s
      status.to_s
    end
  end
end
