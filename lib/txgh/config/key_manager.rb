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
          # gsub replaces non-breaking spaces at beginning of each line
          # can be a problem on heroku
          ENV['TXGH_CONFIG'].gsub(/^[[:space:]]*/) { |s| ' ' * s.size }
        end

        def base_config
          scheme, payload = split_uri(raw_config)

          if provider = provider_for(scheme)
            provider.load(payload)
          else
            raise Txgh::InvalidProviderError,
              "Couldn't find a provider for the '#{scheme}' scheme. Please "\
              "make sure txgh is configured properly."
          end
        end

        def project_config_for(project_name)
          if config = base_config['transifex']['projects'][project_name]
            config.merge('name' => project_name)
          else
            raise Txgh::ProjectConfigNotFoundError,
              "Couldn't find any configuration for the '#{project_name}' project."
          end
        end

        def repo_config_for(repo_name)
          if config = base_config['github']['repos'][repo_name]
            config.merge('name' => repo_name)
          else
            raise Txgh::RepoConfigNotFoundError,
              "Couldn't find any configuration for the '#{repo_name}' repo."
          end
        end
      end
    end
  end
end
