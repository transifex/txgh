require 'yaml'

module Strava
  module Config
    class KeyManager

      def self.github_repo_config(name)
        puts name
        puts yaml.inspect
        yaml['txgh']['github']['repos'][name]
      end

      def self.transifex_project_config(name)
        yaml['txgh']['transifex']['projects'][name]
      end

      def self.yaml
        path = File.join(File.dirname(File.expand_path(__FILE__)), "txgh.yml")
        puts path
        YAML.load(ERB.new(File.read(path)).result)
      end

      private_class_method :new
    end
  end
end
