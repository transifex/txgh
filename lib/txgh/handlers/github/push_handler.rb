require 'base64'
require 'logger'

module Txgh
  module Handlers
    module Github
      class PushHandler
        attr_reader :project, :repo, :payload, :logger

        def initialize(options = {})
          @project = options.fetch(:project)
          @repo = options.fetch(:repo)
          @payload = options.fetch(:payload)
          @logger = options.fetch(:logger) { Logger.new(STDOUT) }
        end

        def execute
          # Check if the branch in the hook data is the configured branch we want
          logger.info("request github branch: #{branch}")
          logger.info("config github branch: #{github_config_branch}")

          if should_process_branch?
            logger.info('found branch in github request')

            tx_resources = tx_resources_for(branch)
            modified_resources = added_and_modified_resources_for(tx_resources)
            modified_resources.merge!(l10n_resources_for(tx_resources))

            if github_config_branch.include?('tags/')
              modified_resources.merge!(tag_resources_for(tx_resources))
            end

            # Handle DBZ 'L10N' special case
            if branch.include?("L10N")
              logger.info('processing L10N tag')

              # Create a new branch off tag commit
              if branch.include?('tags/L10N')
                repo.api.create_ref(repo.name, 'heads/L10N', payload['head_commit']['id'])
              end
            end

            updater = ResourceUpdater.new(project, repo, logger)
            categories = { 'author' => payload['head_commit']['committer']['name'] }

            modified_resources.each_pair do |resource, commit_sha|
              updater.update_resource(resource, commit_sha, categories)
            end
          end
        end

        private

        def tag_resources_for(tx_resources)
          payload['head_commit']['modified'].each_with_object({}) do |modified, ret|
            logger.info("processing modified file: #{modified}")

            if tx_resources.include?(modified)
              ret[tx_resources[modified]] = payload['head_commit']['id']
            end
          end
        end

        def l10n_resources_for(tx_resources)
          payload['head_commit']['modified'].each_with_object({}) do |modified, ret|
            if tx_resources.include?(modified)
              logger.info("setting new resource: #{tx_resources[modified].L10N_resource_slug}")
              ret[tx_resources[modified]] = payload['head_commit']['id']
            end
          end
        end

        # Finds the updated resources and maps the most recent commit in which
        # each was modified
        def added_and_modified_resources_for(tx_resources)
          payload['commits'].each_with_object({}) do |commit, ret|
            logger.info('processing commit')

            (commit['modified'] + commit['added']).each do |file|
              logger.info("processing added/modified file: #{file}")

              if tx_resources.include?(file)
                ret[tx_resources[file]] = commit['id']
              end
            end
          end
        end

        # Build an index of known Tx resources, by source file
        def tx_resources_for(branch)
          tx_config.resources.each_with_object({}) do |resource, ret|
            logger.info('processing resource')

            # If we're processing by branch, create a branch resource. Otherwise,
            # use the original resource.
            ret[resource.source_file] = if upload_by_branch?
              TxBranchResource.new(resource, branch)  # maybe find instead?
            else
              resource
            end
          end
        end

        def tx_config
          @tx_config ||= KeyManager.tx_config(project, repo, branch)
        end

        def should_process_branch?
          process_all_branches? || (
            branch.include?(github_config_branch) || branch.include?('L10N')
          )
        end

        def github_config_branch
          @github_config_branch = begin
            if process_all_branches?
              repo.branch
            else
              branch = repo.branch || 'master'
              Utils.absolute_branch(branch)
            end
          end
        end

        def process_all_branches?
          repo.process_all_branches?
        end

        alias_method :upload_by_branch?, :process_all_branches?

        def branch
          @ref ||= payload['ref'].sub(/^refs\//, '')
        end
      end
    end
  end
end
