module TxghQueue
  module Backends
    autoload :Null, 'txgh-queue/backends/null'
    autoload :Sqs,  'txgh-queue/backends/sqs'

    class BackendNotConfiguredError < StandardError; end

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
