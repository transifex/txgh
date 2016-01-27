require 'erb'
require 'etc'
require 'yaml'

module Txgh
  class KeyManager
    class << self
      def config_from_project(project_name, tx_config = nil)
        project_config = project_config_for(project_name)
        repo_config = repo_config_for(project_config['push_translations_to'])
        tx_config ||= Txgh::TxConfig.load_file(project_config['tx_config'])
        Txgh::Config.new(project_config, repo_config, tx_config)
      end

      def config_from_repo(repo_name, tx_config = nil)
        repo_config = repo_config_for(repo_name)
        project_config = project_config_for(repo_config['push_source_to'])
        tx_config ||= Txgh::TxConfig.load_file(project_config['tx_config'])
        Txgh::Config.new(project_config, repo_config, tx_config)
      end

      def config_from(project_name, repo_name, tx_config = nil)
        project_config = project_config_for(project_name)
        repo_config = repo_config_for(repo_name)
        tx_config ||= Txgh::TxConfig.load_file(project_config['tx_config'])
        Txgh::Config.new(project_config, repo_config, tx_config)
      end

      private :new

      private

      def yaml
        path = if File.file?(File.join(Etc.getpwuid.dir, "txgh.yml"))
          File.join(Etc.getpwuid.dir, "txgh.yml")
        else
          File.expand_path('./config/txgh.yml')
        end

        YAML.load(ERB.new(File.read(path)).result)
      end

      def project_config_for(project_name)
        if config = yaml['txgh']['transifex']['projects'][project_name]
          config.merge('name' => project_name)
        end
      end

      def repo_config_for(repo_name)
        if config = yaml['txgh']['github']['repos'][repo_name]
          config.merge('name' => repo_name)
        end
      end
    end
  end
end
