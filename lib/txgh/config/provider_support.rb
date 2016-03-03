module Txgh
  module Config
    module ProviderSupport
      def register_provider(provider, parser)
        providers << ProviderInstance.new(provider, parser)
      end

      def providers
        @providers ||= []
      end

      def provider_for(scheme)
        providers.find { |provider| provider.supports?(scheme) }
      end

      def split_uri(uri)
        if uri =~ /\A[\w]+:\/\//
          idx = uri.index('://')
          [uri[0...idx], uri[(idx + 3)..-1]]
        else
          [nil, uri]
        end
      end
    end
  end
end
