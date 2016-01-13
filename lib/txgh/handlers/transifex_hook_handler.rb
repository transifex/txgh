require 'logger'

module Txgh
  module Handlers
    class TransifexHookHandler
      attr_reader :project, :repo, :resource, :language, :logger

      def initialize(options = {})
        @project = options.fetch(:project)
        @repo = options.fetch(:repo)
        @resource = options.fetch(:resource)
        @language = options.fetch(:language)
        @logger = options.fetch(:logger) { Logger.new(STDOUT) }
      end

      def execute
        tx_resource = project.resource(resource)

        logger.info(resource)

        # Do not update the source
        unless language == tx_resource.source_lang
          logger.info('request language matches resource')

          translation = project.api.download(tx_resource, language)

          if tx_resource.lang_map(language) != language
            logger.info('request language is in lang_map and is not in request')
            translation_path = tx_resource.translation_path(tx_resource.lang_map(language))
          else
            logger.info('request language is in lang_map and is in request or is nil')
            translation_path = tx_resource.translation_path(project.lang_map(language))
          end

          github_branch = repo.config.fetch('branch', 'master')
          github_branch = github_branch.include?("tags/") ? github_branch : "heads/#{github_branch}"

          logger.info("make github commit for branch: #{github_branch}")

          repo.api.commit(
            repo.name, github_branch, translation_path, translation
          )
        end
      end

    end
  end
end
