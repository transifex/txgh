require 'erb'
require 'etc'
require 'yaml'

module Txgh
  module Config
    class KeyManager
      class << self
        include ProviderSupport

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

        def raw_config
          ENV['TXGH_CONFIG']
        end

        def base_config
          scheme, payload = split_uri(raw_config)
          provider_for(scheme).load(payload)
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
