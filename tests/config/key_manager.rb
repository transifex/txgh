require 'config_env'

module Strava
  module Config
    class KeyManager

      def self.github_repo_config(name)
        ConfigEnv.path_to_config("#{__dir__}/txgh_config.rb")
        ghkeys = ["github_repo_config_api_username", "github_repo_config_api_token", "github_repo_config_push_source_to", "github_repo_config_branch"]
        ghmappings = {"github_repo_config_api_username" => "api_username", "github_repo_config_branch" => "branch", "github_repo_config_api_token" => "api_token", "github_repo_config_push_source_to" => "push_source_to"}
        @config = ConfigEnv.vars
        @config.keep_if {|k,_| ghkeys.include? k }
        @config.keys.each { |k| @config[ ghmappings[k] ] = @config.delete(k) if ghmappings[k] }
        puts @config

        @config
      end

      def self.transifex_project_config(name)
        ConfigEnv.path_to_config("#{__dir__}/txgh_config.rb")
        txkeys = ["transifex_project_config_tx_config","transifex_project_config_api_username","transifex_project_config_api_password", "transifex_project_config_push_translations_to" ]
        txmappings = {"transifex_project_config_tx_config" => "tx_config", "transifex_project_config_api_username" => "api_username", "transifex_project_config_api_password" => "api_password", "transifex_project_config_push_translations_to" => "push_translations_to" }
        @config = ConfigEnv.vars
        @config.keep_if {|k,_| txkeys.include? k }
        @config.keys.each { |k| @config[ txmappings[k] ] = @config.delete(k) if txmappings[k] }
        puts @config
        

        @config
      end

      private_class_method :new
    end
  end
end