require 'erb'
require 'etc'
require 'yaml'

module Txgh
  module Config
    class KeyManager
      class << self
        def config_from_project(project_name)
          project_config = project_config_for(project_name)
          repo_config = repo_config_for(project_config['push_translations_to'])
          ConfigPair.new(project_config, repo_config)
        end

        def config_from_repo(repo_name)
          repo_config = repo_config_for(repo_name)
          project_config = project_config_for(repo_config['push_source_to'])
          ConfigPair.new(project_config, repo_config)
        end

        def config_from(project_name, repo_name)
          project_config = project_config_for(project_name)
          repo_config = repo_config_for(repo_name)
          ConfigPair.new(project_config, repo_config)
        end

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
                  'protected_branches' => ENV['PROTECTED_BRANCHES'],
                  'webhook_secret' => ENV['TX_WEBHOOK_SECRET'],
                  'auto_delete_resources' => ENV['AUTO_DELETE_RESOURCES']
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
end
