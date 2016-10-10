require 'txgh'

module TxghQueue
  module Backends
    module Sqs
      autoload :Config,            'txgh-queue/backends/sqs/config'
      autoload :Consumer,          'txgh-queue/backends/sqs/consumer'
      autoload :HistorySequence,   'txgh-queue/backends/sqs/history_sequence'
      autoload :Job,               'txgh-queue/backends/sqs/job'
      autoload :MessageAttributes, 'txgh-queue/backends/sqs/message_attributes'
      autoload :Producer,          'txgh-queue/backends/sqs/producer'
      autoload :Queue,             'txgh-queue/backends/sqs/queue'
      autoload :RetryLogic,        'txgh-queue/backends/sqs/retry_logic'

      class << self
        def producer_for(events, logger = Txgh::TxLogger.logger)
          Producer.new(find_queues_for(Array(events)), logger)
        end

        def consumer_for(events, logger = Txgh::TxLogger.logger)
          Consumer.new(find_queues_for(Array(events)), logger)
        end

        private

        def find_queues_for(events)
          queues = events.flat_map do |event|
            Config.queues.select { |queue| queue.events.include?(event) }
          end

          queues.uniq
        end
      end
    end
  end
end
