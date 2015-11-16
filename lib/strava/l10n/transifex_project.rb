require 'config/key_manager'
require 'strava/l10n/github_repo'
require 'strava/l10n/transifex_api'
require 'strava/l10n/tx_config'

module Strava
  module L10n
    class TransifexProject
      def initialize(project_name)
        @name = project_name
        Strava::Config::KeyManager.load_yaml(nil,project_name)
        @config = Strava::Config::KeyManager.transifex_project_config
        @tx_config = Strava::L10n::TxConfig.new(@config['tx_config'])
      end

      def github_repo
        @github_repo = @github_repo ||
            Strava::L10n::GitHubRepo.new(@config['push_translations_to'])
      end
      
      def resource(slug)
        @tx_config.resources.each do |resource|
          return resource if resource.resource_slug == slug
        end
      end

      def resources
        @tx_config.resources
      end

      def api
        @api = @api || Strava::L10n::TransifexApi.instance(
            @config['api_username'], @config['api_password'])
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
end

