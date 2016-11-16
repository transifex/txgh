module Txgh
  class ResourceDeleter
    include Txgh::CategorySupport

    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch, options = {})
      @project = project
      @repo = repo
      @branch = branch
    end

    def delete_resources
      tx_resources.each do |tx_resource|
        project.api.delete_resource(tx_resource)
      end
    end

    private

    def tx_resources
      project.api.get_resources(project.name).map do |resource_hash|
        categories = deserialize_categories(resource_hash['categories'])
        resource_branch = Txgh::Utils.absolute_branch(categories['branch'])

        if resource_branch == branch
          tx_branch_resource_from(resource_hash, branch)
        end
      end.compact
    end

    def tx_branch_resource_from(resource_hash, branch)
      Txgh::TxBranchResource.new(
        tx_resource_from(resource_hash, branch), branch
      )
    end

    # project_slug, resource_slug, type, source_lang, source_file, lang_map, translation_file
    def tx_resource_from(resource_hash, branch)
      Txgh::TxResource.new(
        project.name,
        Txgh::TxBranchResource.deslugify(resource_hash['slug'], branch),
        resource_hash['i18n_type'],
        resource_hash['source_language_code'],
        resource_hash['name'],
        {}, nil
      )
    end
  end
end
