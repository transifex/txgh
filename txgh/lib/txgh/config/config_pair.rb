module Txgh
  module Config
    class ConfigPair
      attr_reader :project_config, :repo_config

      def initialize(project_config, repo_config)
        @project_config = project_config
        @repo_config = repo_config
      end

      def git_repo
        @git_repo ||= if @repo_config['git_repo_source'] == 'gitlab'
                        Txgh::GitlabRepo.new(repo_config, gitlab_api)
                      else
                        Txgh::GithubRepo.new(repo_config, github_api)
                      end
      end

      def transifex_project
        @transifex_project ||= Txgh::TransifexProject.new(
          project_config, transifex_api
        )
      end

      def transifex_api
        @transifex_api ||= Txgh::TransifexApi.create_from_credentials(
          project_config['api_username'], project_config['api_password']
        )
      end

      def github_api
        @github_api ||= Txgh::GithubApi.create_from_credentials(
          repo_config['api_username'], repo_config['api_token'], repo_config['name']
        )
      end

      def gitlab_api
        @gitlab_api ||= Txgh::GitlabApi.create_from_credentials(
          nil, repo_config['api_token'], repo_config['name']
        )
      end
    end
  end
end
