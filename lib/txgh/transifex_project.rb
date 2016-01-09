module Txgh
  class TransifexProject
    def initialize(project_name)
      @name = project_name
      Txgh::KeyManager.load_yaml(nil, project_name)
      @config = Txgh::KeyManager.transifex_project_config
      @tx_config = Txgh::TxConfig.new(@config['tx_config'])
    end

    def github_repo
      @github_repo ||=
        Txgh::GitHubRepo.new(@config['push_translations_to'])
    end

    def resource(slug)
      @tx_config.resources.find do |resource|
        resource.resource_slug == slug
      end
    end

    def resources
      @tx_config.resources
    end

    def api
      @api ||= Txgh::TransifexApi.instance(
        @config['api_username'], @config['api_password']
      )
    end

    def lang_map(tx_lang)
      if @tx_config.lang_map.include?(tx_lang)
        @tx_config.lang_map[tx_lang]
      else
        tx_lang
      end
    end
  end
end
