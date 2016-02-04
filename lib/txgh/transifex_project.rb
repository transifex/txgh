module Txgh
  class TransifexProject
    attr_reader :config, :tx_config, :api

    def initialize(config, tx_config, api)
      @config = config
      @tx_config = tx_config
      @api = api
    end

    def name
      config['name']
    end
    
    def webhook_secret
      config['webhook_secret']
    end

    def webhook_protected?
      !(webhook_secret || '').empty?
    end

    def resource(slug, branch = nil)
      if branch
        TxBranchResource.find(self, slug, branch)
      else
        tx_config.resources.find do |resource|
          resource.resource_slug == slug
        end
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
  end
end
