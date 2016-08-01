require 'logger'

module TxghServer
  module Webhooks
    module Transifex
      class HookHandler
        include Txgh::CategorySupport
        include ResponseHelpers

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

          check_error_response || begin
            committer = Txgh::ResourceCommitter.new(project, repo, logger)
            committer.commit_resource(tx_resource, branch, language)
            respond_with(200, true)
          end
        end

        private

        def check_error_response
          check_supported_language || check_tx_config || check_tx_resource
        end

        def check_supported_language
          respond_with(304, true) unless supported_language?
        end

        def check_tx_config
          unless tx_config
            respond_with_error(
              404, "Could not find configuration for branch '#{branch}'"
            )
          end
        end

        def check_tx_resource
          unless tx_resource
            respond_with_error(
              404, "Could not find resource '#{resource_slug}' in config"
            )
          end
        end

        def tx_config
          @tx_config ||= Txgh::Config::TxManager.tx_config(project, repo, branch)
        rescue ConfigNotFoundError, TxghError
          nil
        end

        def branch
          @branch ||= begin
            branch_candidate = if process_all_branches?
              resource = project.api.get_resource(project.name, resource_slug)
              categories = deserialize_categories(Array(resource['categories']))
              categories['branch']
            else
              repo.branch || 'master'
            end

            Txgh::Utils.absolute_branch(branch_candidate)
          end
        end

        def tx_resource
          @tx_resource ||= if process_all_branches?
            tx_config.resource(resource_slug, branch)
          else
            tx_config.resource(resource_slug)
          end
        end

        def process_all_branches?
          repo.process_all_branches?
        end

        def supported_language?
          project.supported_language?(language)
        end
      end
    end
  end
end
