module Txgh
  module Config
    module ProviderSupport
      def register_provider(provider, parser, options = {})
        providers << ProviderInstance.new(provider, parser, options)
      end

      def providers
        @providers ||= []
      end

      def provider_for(scheme)
        provider = providers.find { |provider| provider.supports?(scheme) }
        provider || providers.find(&:default?)
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
