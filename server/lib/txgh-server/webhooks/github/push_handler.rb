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
          logger.info("config github branch: #{repo.github_config_branch}")

          if should_process?
            logger.info('found branch in github request')

            pusher.push_resources(added_and_modified_resources) do |tx_resource|
              # block should return categories for the passed-in resource
              { 'author' => attributes.author }
            end

            update_github_status
          end

          respond_with(200, true)
        rescue => e
          error_params = Txgh.events.publish_error!(e)

          Txgh.events.publish_each('github.status.error', error_params) do |status_params|
            update_github_status_with_error(status_params) if status_params
          end

          respond_with_error(500, "Internal server error: #{e.message}", e)
        end

        private

        def update_github_status_with_error(status_params)
          update_github_status_safely do
            Txgh::GithubStatus.error(project, repo, branch, status_params)
          end
        end

        def update_github_status
          update_github_status_safely do
            Txgh::GithubStatus.update(project, repo, branch)
          end
        end

        def update_github_status_safely
          yield
        rescue Octokit::UnprocessableEntity
          # raised because we've tried to create too many statuses for the commit
        rescue Txgh::TransifexNotFoundError
          # raised if transifex resource can't be found
        end

        def pusher
          @pusher ||= Txgh::Pusher.new(project, repo, branch)
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
