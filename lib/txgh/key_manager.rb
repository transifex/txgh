require 'yaml'
require 'etc'

module Txgh
  class KeyManager
    class << self
      attr_reader :github_repo_config, :transifex_project_config

      def load_yaml(github_repository_name, transifex_project_name)
        @github_repo_config = yaml['txgh']['github']['repos'][github_repository_name]
        @transifex_project_config = yaml['txgh']['transifex']['projects'][transifex_project_name]
      end

      def yaml
        path = if File.file?(File.join(Etc.getpwuid.dir, "txgh.yml"))
          File.join(Etc.getpwuid.dir, "txgh.yml")
        else
          File.expand_path('../../../config/txgh.yml', __FILE__)
        end

        YAML.load(ERB.new(File.read(path)).result)
      end

      private :new
    end
  end
end
