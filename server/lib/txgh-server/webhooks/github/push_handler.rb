require 'set'

module TxghServer
  module Webhooks
    module Github
      class PushHandler
        include ResponseHelpers

        attr_reader :project, :repo, :logger, :attributes

        def initialize(project, repo, logger, attributes)
          @project = project
          @repo = repo
          @logger = logger
          @attributes = attributes
        end

        def execute
          # Check if the branch in the hook data is the configured branch we want
          logger.info("request github branch: #{branch}")
          logger.info("config github branch: #{repo.github_config_branch}")

          if should_process?
            logger.info('found branch in github request')

            updater = Txgh::ResourceUpdater.new(project, repo, logger)
            categories = { 'author' => attributes.author }

            added_and_modified_resources.each do |resource|
              updater.update_resource(resource, categories)
            end
          end

          respond_with(200, true)
        end

        private

        # finds the resources that were updated in each commit
        def added_and_modified_resources
          attributes.files.each_with_object(Set.new) do |file, ret|
            logger.info("processing added/modified file: #{file}")

            if tx_resources.include?(file)
              ret << tx_resources[file]
            end
          end
        end

        # Build an index of known Tx resources, by source file
        def tx_resources
          @tx_resources ||= tx_config.resources.each_with_object({}) do |resource, ret|
            ret[resource.source_file] = if repo.process_all_branches?
              Txgh::TxBranchResource.new(resource, branch)  # maybe find instead?
            else
              resource
            end
          end
        end

        def tx_config
          @tx_config ||= Txgh::Config::TxManager.tx_config(project, repo, branch)
        end

        def branch
          @ref ||= attributes.ref.sub(/^refs\//, '')
        end

        def should_process?
          should_process_branch? && should_process_commit?
        end

        def should_process_branch?
          repo.should_process_ref?(branch)
        end

        def should_process_commit?
          # return false if 'after' commit sha is all zeroes (indicates branch
          # has been deleted)
          !((attributes.after || '') =~ /\A0+\z/)
        end

      end
    end
  end
end
