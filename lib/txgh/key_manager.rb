require 'erb'
require 'etc'
require 'yaml'

module Txgh
  class KeyManager
    class << self
      def config_from_project(project_name)
        project_config = project_config_for(project_name)
        repo_config = repo_config_for(project_config['push_translations_to'])
        Txgh::Config.new(project_config, repo_config)
      end

      def config_from_repo(repo_name)
        repo_config = repo_config_for(repo_name)
        project_config = project_config_for(repo_config['push_source_to'])
        Txgh::Config.new(project_config, repo_config)
      end

      def config_from(project_name, repo_name)
        project_config = project_config_for(project_name)
        repo_config = repo_config_for(repo_name)
        Txgh::Config.new(project_config, repo_config)
      end

      def tx_config(transifex_project, github_repo, ref = nil)
        scheme, payload = split_uri(transifex_project.tx_config_uri)

        case scheme
          when 'raw'
            Txgh::TxConfig.load(payload)
          when 'file'
            Txgh::TxConfig.load_file(payload)
          when 'git'
            unless ref
              raise TxghError,
                "TX_CONFIG specified a file from git but did not provide a ref."
            end

            Txgh::TxConfig.load(
              github_repo.api.download(github_repo.name, payload, ref)
            )
        end
      end

      private :new

      private

      def split_uri(uri)
        if uri =~ /\A[\w]+:\/\//
          idx = uri.index('://')
          [uri[0...idx], uri[(idx + 3)..-1]]
        else
          [nil, uri]
        end
      end

      def base_config
        {
          'github' => {
            'repos' => {
              ENV['TX_PUSH_TRANSLATIONS_TO'] => {
                'api_username' => ENV['GITHUB_USERNAME'],
                'api_token' => ENV['GITHUB_TOKEN'],
                'push_source_to' => ENV['GITHUB_PUSH_SOURCE_TO'],
                'branch' => ENV['GITHUB_BRANCH'],
                'webhook_secret' => ENV['GITHUB_WEBHOOK_SECRET']
              }
            }
          },

          'transifex' => {
            'projects' => {
              ENV['GITHUB_PUSH_SOURCE_TO'] => {
                'tx_config' => ENV['TX_CONFIG_PATH'],
                'api_username' => ENV['TX_USERNAME'],
                'api_password' => ENV['TX_PASSWORD'],
                'push_translations_to' => ENV['TX_PUSH_TRANSLATIONS_TO'],
                'webhook_secret' => ENV['TX_WEBHOOK_SECRET']
              }
            }
          }
        }
      end

      def project_config_for(project_name)
        if config = base_config['transifex']['projects'][project_name]
          config.merge('name' => project_name)
        end
      end

      def repo_config_for(repo_name)
        if config = base_config['github']['repos'][repo_name]
          config.merge('name' => repo_name)
        end
      end
    end
  end
end
