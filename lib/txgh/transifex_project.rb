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

    def tx_config_uri
      config['tx_config']
    end
  end
end
