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

    def organization
      config['organization']
    end

    def webhook_secret
      config['webhook_secret']
    end

    def protected_branches
      @protected_branches ||=
        (config['protected_branches'] || '').split(',').map do |branch|
          Utils.absolute_branch(branch.strip)
        end
    end

    def webhook_protected?
      !(webhook_secret || '').empty?
    end

    def auto_delete_resources?
      Utils.booleanize(config['auto_delete_resources'] || 'false')
    end

    def tx_config_uri
      config['tx_config']
    end

    def languages
      config.fetch('languages', [])
    end

    def serialization_options
      config['serialization_options']
    end

    def supported_language?(language)
      languages.include?(language)
    end
  end
end
