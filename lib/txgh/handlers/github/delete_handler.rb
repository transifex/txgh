module Txgh
  module Handlers
    module Github
      class DeleteHandler < Handler

        def execute
          if should_handle_request?
            if tx_config
              delete_resources
              respond_with(200, true)
            else
              respond_with_error(
                404, "Could not find configuration for branch '#{branch}'"
              )
            end
          else
            respond_with(200, true)
          end
        end

        private

        def delete_resources
          tx_resources.each do |tx_resource|
            logger.info("Deleting #{tx_resource.resource_slug}")
            project.api.delete(tx_resource)
          end
        end

        def tx_config
          @tx_config ||= Txgh::KeyManager.tx_config(project, repo, branch)
        rescue ConfigNotFoundError, TxghError
          nil
        end

        def tx_resources
          @tx_resources ||= tx_config.resources.map do |tx_resource|
            branch_resource = tx_config.resource(tx_resource.resource_slug, branch)

            if branch_resource && project.api.resource_exists?(branch_resource)
              branch_resource
            end
          end.compact
        end

        def should_handle_request?
          # ref_type can be either 'branch' or 'tag' - we only care about branches
          payload['ref_type'] == 'branch' &&
            repo.should_process_branch?(branch) &&
            project.auto_delete_resources?
        end

        def branch
          Utils.absolute_branch(payload['ref'].sub(/^refs\//, ''))
        end

      end
    end
  end
end
