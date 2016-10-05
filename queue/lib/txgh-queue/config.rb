require 'yaml'

module TxghQueue
  class Config
    class << self
      def backend
        TxghQueue::Backends.get(raw_config[:backend])
      end

      def options
        raw_config[:options]
      end

      def reset!
        @raw_config = nil
      end

      private

      def raw_config
        @raw_config ||= begin
          scheme, payload = ENV['TXGH_QUEUE_CONFIG'].split('://')
          send(:"load_#{scheme}", payload)
        end
      end

      def load_file(payload)
        Txgh::Utils.deep_symbolize_keys(YAML.load_file(payload))
      end

      def load_raw(payload)
        Txgh::Utils.deep_symbolize_keys(YAML.load(payload))
      end
    end
  end
end
