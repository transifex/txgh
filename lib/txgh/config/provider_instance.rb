module Txgh
  module Config
    class ProviderInstance
      attr_reader :provider, :parser, :options

      def initialize(provider, parser, options = {})
        @provider = provider
        @parser = parser
        @options = options
      end

      def supports?(*args)
        provider.supports?(*args)
      end

      def load(payload, options = {})
        provider.load(payload, parser, options)
      end

      def default?
        !!(options[:default])
      end
    end
  end
end
