module Txgh
  class TransifexProject
    attr_reader :config, :api

    def initialize(config, api)
      @config = config
      @api = api
    end

    def name
      config['name']
    end

    def resource(slug)
      tx_config.resources.find do |resource|
        resource.resource_slug == slug
      end
    end

    def resources
      tx_config.resources
    end

    def lang_map(tx_lang)
      if tx_config.lang_map.include?(tx_lang)
        tx_config.lang_map[tx_lang]
      else
        tx_lang
      end
    end

    private

    def tx_config
      @tx_config ||= Txgh::TxConfig.new(config['tx_config'])
    end
  end
end
