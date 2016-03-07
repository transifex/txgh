module Txgh
  module Config
    class ProviderInstance
      attr_reader :provider, :parser

      def initialize(provider, parser)
        @provider = provider
        @parser = parser
      end

      def supports?(*args)
        provider.supports?(*args)
      end

      def load(payload, options = {})
        provider.load(payload, parser, options)
      end
    end
  end
end
