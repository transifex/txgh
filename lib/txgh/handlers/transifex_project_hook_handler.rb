require 'logger'

module Txgh
  module Handlers
    class TransifexProjectHookHandler
      attr_reader :project, :new_config, :logger

      def initialize(options = {})
        @project = options.fetch(:project)
        @new_config = options.fetch(:new_config)
        @logger = options.fetch(:logger) { Logger.new(STDOUT) }
      end

      def execute
        logger.info("Processing config update for #{project.name}")

        project_config_file_path = project.config['tx_config']
        project_config = ParseConfig.load(new_config)

        logger.info("Writing new configuration to #{project_config_file_path}")

        File.open(project_config_file_path, 'w+') do |file|
          project_config.write(file)
        end

        logger.info("Project configuration updated!")
      end
    end
  end
end
