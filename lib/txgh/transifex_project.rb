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

    def webhook_secret
      config['webhook_secret']
    end

    def protected_branches
      @protected_branches ||=
        config.fetch('protected_branches', '').split(',').map do |branch|
          Utils.absolute_branch(branch.strip)
        end
    end

    def webhook_protected?
      !(webhook_secret || '').empty?
    end

    def auto_delete_resources?
      (config['auto_delete_resources'] || '').downcase == 'true'
    end

    def tx_config_uri
      config['tx_config']
    end
  end
end
