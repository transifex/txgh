module Txgh
  class Config
    attr_reader :project_config, :repo_config

    def initialize(project_config, repo_config)
      @project_config = project_config
      @repo_config = repo_config
    end

    def github_repo
      @github_repo ||= Txgh::GitHubRepo.new(repo_config, github_api)
    end

    def transifex_project
      @transifex_project ||= Txgh::TransifexProject.new(
        project_config, transifex_api
      )
    end

    def transifex_api
      @transifex_api ||= Txgh::TransifexApi.instance(
        project_config['api_username'], project_config['api_password']
      )
    end

    def github_api
      @github_api ||= Txgh::GitHubApi.new(
        repo_config['api_username'], repo_config['api_token']
      )
    end
  end
end
