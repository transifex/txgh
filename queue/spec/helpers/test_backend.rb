module TxghQueue
  class TestBackend
    class << self
      def producer_for(event, logger = Txgh::TxLogger.logger)
        producers[event] ||= TestProducer.new(event, logger)
      end

      def consumer_for(event, logger = Txgh::TxLogger.logger)
        consumers[event] ||= TestConsumer.new(event, logger)
      end

      def reset!
        @producers = nil
        @consumers = nil
      end

      private

      def producers
        @producers ||= {}
      end

      def consumers
        @consumers ||= {}
      end
    end
  end

  class TestProducer
    attr_reader :queue_names, :logger, :enqueued_jobs

    def initialize(event, logger)
      @event = event
      @logger = logger
      @enqueued_jobs = []
    end

    def enqueue(payload, options = {})
      enqueued_jobs << { payload: payload, options: options }
    end
  end

  class TestConsumer
    attr_reader :queue_names, :logger

    def initialize(event, logger)
      @event = event
      @logger = logger
    end

    def work
    end
  end
end
