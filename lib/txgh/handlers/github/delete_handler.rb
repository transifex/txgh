module Txgh
  module Handlers
    module Github
      class DeleteHandler < Handler

        include CategorySupport

        def execute
          delete_resources if should_handle_request?
          respond_with(200, true)
        end

        private

        def delete_resources
          tx_resources.each do |tx_resource|
            logger.info("Deleting #{tx_resource.resource_slug}")
            project.api.delete(tx_resource)
          end
        end

        def tx_resources
          project.api.get_resources(project.name).map do |resource_hash|
            categories = deserialize_categories(resource_hash['categories'])
            resource_branch = Utils.absolute_branch(categories['branch'])

            if resource_branch == branch
              tx_branch_resource_from(resource_hash, branch)
            end
          end.compact
        end

        def tx_branch_resource_from(resource_hash, branch)
          TxBranchResource.new(
            tx_resource_from(resource_hash, branch), branch
          )
        end

        # project_slug, resource_slug, type, source_lang, source_file, lang_map, translation_file
        def tx_resource_from(resource_hash, branch)
          TxResource.new(
            project.name,
            TxBranchResource.deslugify(resource_hash['slug'], branch),
            resource_hash['i18n_type'],
            resource_hash['source_language_code'],
            resource_hash['name'],
            '', nil
          )
        end

        def should_handle_request?
          # ref_type can be either 'branch' or 'tag' - we only care about branches
          payload['ref_type'] == 'branch' &&
            repo.should_process_ref?(branch) &&
            project.auto_delete_resources?
        end

        def branch
          Utils.absolute_branch(payload['ref'].sub(/^refs\//, ''))
        end

      end
    end
  end
end
