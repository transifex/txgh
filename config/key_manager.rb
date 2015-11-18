require 'yaml'
require 'etc'


module Strava
  module Config
    class KeyManager

      @github_repo_config
      @transifex_project_config


      def self.github_repo_config
        @github_repo_config
      end

      def self.transifex_project_config
        @transifex_project_config
      end

      def self.load_yaml(github_repository_name, transifex_project_name)
        @github_repo_config = yaml['txgh']['github']['repos'][github_repository_name]
        @transifex_project_config = yaml['txgh']['transifex']['projects'][transifex_project_name]
      end

      def self.yaml
        path = File.file?(File.join(Etc.getpwuid.dir, "txgh.yml"))?
          File.join(Etc.getpwuid.dir, "txgh.yml"):
          File.join(File.dirname(File.expand_path(__FILE__)), "txgh.yml")
        YAML.load(ERB.new(File.read(path)).result)
      end

      private_class_method :new
    end
  end
end