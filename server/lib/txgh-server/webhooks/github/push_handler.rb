require 'base64'
require 'set'

module TxghServer
  module Webhooks
    module Github
      class PushHandler < Handler

        def execute
          # Check if the branch in the hook data is the configured branch we want
          logger.info("request github branch: #{branch}")
          logger.info("config github branch: #{repo.github_config_branch}")

          if should_process?
            logger.info('found branch in github request')

            tx_resources = tx_resources_for(branch)

            modified_resources = added_and_modified_resources_for(tx_resources)
            modified_resources += l10n_resources_for(tx_resources)

            if repo.github_config_branch.include?('tags/')
              modified_resources += tag_resources_for(tx_resources)
            end

            # Handle DBZ 'L10N' special case
            if branch.include?("L10N")
              logger.info('processing L10N tag')

              # Create a new branch off tag commit
              if branch.include?('tags/L10N')
                repo.api.create_ref(repo.name, 'heads/L10N', payload['head_commit']['id'])
              end
            end

            updater = Txgh::ResourceUpdater.new(project, repo, logger)
            categories = { 'author' => payload['head_commit']['committer']['name'] }
            ref = repo.api.get_ref(repo.name, branch)

            modified_resources.each do |resource|
              updater.update_resource(resource, ref[:object][:sha], categories)
            end
          end

          respond_with(200, true)
        end

        private

        def tag_resources_for(tx_resources)
          payload['head_commit']['modified'].each_with_object(Set.new) do |modified, ret|
            logger.info("processing modified file: #{modified}")

            if tx_resources.include?(modified)
              ret << tx_resources[modified]
            end
          end
        end

        def l10n_resources_for(tx_resources)
          payload['head_commit']['modified'].each_with_object(Set.new) do |modified, ret|
            if tx_resources.include?(modified)
              logger.info("setting new resource: #{tx_resources[modified].L10N_resource_slug}")
              ret << tx_resources[modified]
            end
          end
        end

        # finds the resources that were updated in each commit
        def added_and_modified_resources_for(tx_resources)
          payload['commits'].each_with_object(Set.new) do |commit, ret|
            logger.info('processing commit')

            (commit['modified'] + commit['added']).each do |file|
              logger.info("processing added/modified file: #{file}")

              if tx_resources.include?(file)
                ret << tx_resources[file]
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
          @ref ||= payload['ref'].sub(/^refs\//, '')
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
          !(payload.fetch('after', '') =~ /\A0+\z/)
        end

      end
    end
  end
end
