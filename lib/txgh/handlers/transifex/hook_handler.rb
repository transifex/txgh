require 'logger'

module Txgh
  module Handlers
    module Transifex
      class HookHandler
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
            committer = ResourceCommitter.new(project, repo, logger)
            committer.commit_resource(tx_resource, branch, language)
          else
            [
              404,
              [{
                error: "Could not find configuration for resource '#{resource_slug}'"
              }]
            ]
          end

          [200, {}]
        end

        private

        def tx_config
          @tx_config ||= Txgh::KeyManager.tx_config(project, repo, branch)
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

            Utils.absolute_branch(branch_candidate)
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
      end
    end
  end
end
