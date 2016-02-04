require 'logger'

module Txgh
  module Handlers
    class TransifexHookHandler
      include Txgh::CategorySupport

      attr_reader :project, :repo, :resource_slug, :language, :logger

      def initialize(options = {})
        @project = options.fetch(:project)
        @repo = options.fetch(:repo)
        @resource_slug = options.fetch(:resource_slug)
        @language = options.fetch(:language)
        @logger = options.fetch(:logger) { Logger.new(STDOUT) }
      end

      def execute
        logger.info(resource_slug)

        if tx_resource
        # Do not update the source
          unless language == tx_resource.source_lang
            logger.info('request language matches resource')

            translations = project.api.download(tx_resource, language)

            translation_path = if tx_resource.lang_map(language) != language
              logger.info('request language is in lang_map and is not in request')
              tx_resource.translation_path(tx_resource.lang_map(language))
            else
              logger.info('request language is in lang_map and is in request or is nil')
              tx_resource.translation_path(project.lang_map(language))
            end

            logger.info("make github commit for branch: #{branch}")

            repo.api.commit(
              repo.name, branch, translation_path, translations
            )
          end
        else
          raise TxghError,
            "Could not find configuration for resource '#{resource_slug}'"
        end
      end

      private

      def branch
        branch_candidate = if process_all_branches?
          tx_resource.branch
        else
          repo.branch || 'master'
        end

        if branch_candidate.include?('tags/')
          branch_candidate
        elsif branch_candidate.include?('heads/')
          branch_candidate
        else
          "heads/#{branch_candidate}"
        end
      end

      def tx_resource
        @tx_resource ||= if process_all_branches?
          resource = project.api.get_resource(project.name, resource_slug)
          categories = deserialize_categories(Array(resource['categories']))
          project.resource(resource_slug, categories['branch'])
        else
          project.resource(resource_slug)
        end
      end

      def process_all_branches?
        repo.branch == 'all'
      end
    end
  end
end
