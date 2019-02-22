require 'erb'
require 'yaml'

module TxghQueue
  class Config
    DEFAULT_BACKEND = 'null'

    class << self
      def backend
        TxghQueue::Backends.get(
          raw_config.fetch(:backend, DEFAULT_BACKEND)
        )
      end

      def processing_enabled?
        raw_config.fetch(:processing_enabled, true)
      end

      def options
        raw_config.fetch(:options, {})
      end

      def reset!
        @raw_config = nil
      end

      private

      def raw_config
        @raw_config ||= begin
          if ENV['TXGH_QUEUE_CONFIG']
            scheme, payload = ENV['TXGH_QUEUE_CONFIG'].split('://')
            send(:"load_#{scheme}", payload)
          else
            {}
          end
        end
      end

      def load_file(payload)
        Txgh::Utils.deep_symbolize_keys(parse(File.read(payload)))
      end

      def load_raw(payload)
        Txgh::Utils.deep_symbolize_keys(parse(payload))
      end

      def parse(str)
        YAML.load(ERB.new(str).result(binding))
      end
    end
  end
end
