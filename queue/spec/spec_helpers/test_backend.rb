module TxghQueue
  class TestBackend
    class << self
      def producer_for(queue_name, logger = Txgh::TxLogger.logger)
        TestProducer.new(queue_name, logger)
      end

      def consumer_for(queue_names, logger = Txgh::TxLogger.logger)
        TestConsumer.new(queue_names, logger)
      end
    end
  end

  class TestProducer
    attr_reader :queue_names, :logger

    def initialize(queue_name, logger)
      @queue_name = queue_name
      @logger = logger
    end

    def enqueue(payload, options = {})
    end
  end

  class TestConsumer
    attr_reader :queue_names, :logger

    def initialize(queue_names, logger)
      @queue_names = queue_names
      @logger = logger
    end

    def work
    end
  end
end
