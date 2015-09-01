require 'config/key_manager'
require 'strava/l10n/github_api'
require 'strava/l10n/transifex_project'
require 'strava/l10n/tx_config'

module Strava
  module L10n
    class GitHubRepo

      def initialize(name)
        @name = name
        @config = Strava::Config::KeyManager.github_repo_config(name)
        @branch = @config['branch']
      end

      def name
        @name
      end

      def branch
        @branch
      end

      def transifex_project
        @transifex_project = @transifex_project ||
            Strava::L10n::TransifexProject.new(@config['push_source_to'])
      end

      def api
        @api = @api || Strava::L10n::GitHubApi.new(
            @config['api_username'], @config['api_token'])
      end

    end
  end
end
