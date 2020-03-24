require 'set'
require 'octokit'
require 'txgh'

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
          logger.info("config github branch: #{repo.git_config_branch}")

          if should_process?
            logger.info('found branch in github request')

            pusher.push_resources(added_and_modified_resources) do |tx_resource|
              # block should return categories for the passed-in resource
              { 'author' => attributes.author }
            end

            status_updater.update_status
          end

          respond_with(200, true)
        rescue => e
          status_updater.report_error_and_update_status(e)
          respond_with_error(500, "Internal server error: #{e.message}", e)
        end

        private

        def pusher
          @pusher ||= Txgh::Pusher.new(project, repo, branch)
        end

        def status_updater
          @status_updater = StatusUpdater.new(project, repo, branch)
        end

        # finds the resources that were updated in each commit
        def added_and_modified_resources
          @amr ||= attributes.files.each_with_object(Set.new) do |file, ret|
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
