module Txgh
  class GithubRepo
    attr_reader :config, :api

    def initialize(config, api)
      @config = config
      @api = api
    end

    def name
      config['name']
    end

    def branch
      config['branch']
    end

    def process_all_branches?
      branch == 'all'
    end

    def webhook_secret
      config['webhook_secret']
    end

    def webhook_protected?
      !(webhook_secret || '').empty?
    end
  end
end
