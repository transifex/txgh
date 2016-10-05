module TxghQueue
  module Backends
    autoload :Sqs, 'txgh-queue/backends/sqs'

    class << self
      def register(name, klass)
        all[name] = klass
      end

      def get(name)
        all[name]
      end

      def all
        @all ||= {}
      end
    end
  end
end
