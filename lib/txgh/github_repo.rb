module Txgh
  class GitHubRepo
    attr_reader :name, :branch, :config

    def initialize(name)
      @name = name
      Txgh::KeyManager.load_yaml(name,nil)
      @config = Txgh::KeyManager.github_repo_config
      @branch = @config['branch']
    end

    def transifex_project
      @transifex_project ||=
        Txgh::TransifexProject.new(@config['push_source_to'])
    end

    def api
      @api ||= Txgh::GitHubApi.new(
        config['api_username'], config['api_token']
      )
    end
  end
end
