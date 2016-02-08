module Txgh
  class ResourceUpdater
    include Txgh::CategorySupport

    attr_reader :project, :repo, :logger

    def initialize(project, repo, logger = nil)
      @project = project
      @repo = repo
      @logger = logger || Logger.new(STDOUT)
    end

    # For each modified resource, get its content and update the content
    # in Transifex.
    def update_resource(tx_resource, commit_sha, categories = {})
      logger.info('process updated resource')
      github_api = repo.api
      tree_sha = github_api.get_commit(repo.name, commit_sha)['commit']['tree']['sha']
      tree = github_api.tree(repo.name, tree_sha)

      tree['tree'].each do |file|
        logger.info("process each tree entry: #{file['path']}")

        if tx_resource.source_file == file['path']
          logger.info("process resource file: #{tx_resource.source_file}")
          blob = github_api.blob(repo.name, file['sha'])
          content = blob['encoding'] == 'utf-8' ? blob['content'] : Base64.decode64(blob['content'])

          if repo.process_all_branches?
            upload_by_branch(tx_resource, content, categories)
          else
            upload(tx_resource, content)
          end

          logger.info "updated tx_resource: #{tx_resource.inspect}"
        end
      end
    end

    private

    def upload(tx_resource, content)
      project.api.create_or_update(tx_resource, content)
    end

    def upload_by_branch(tx_resource, content, additional_categories)
      resource_exists = project.api.resource_exists?(tx_resource)
      categories = resource_exists ? categories_for(tx_resource) : {}
      categories.merge!(additional_categories)
      categories['branch'] ||= tx_resource.branch
      categories = serialize_categories(categories)

      if resource_exists
        project.api.update_details(tx_resource, categories: categories)
        project.api.update_content(tx_resource, content)
      else
        project.api.create(tx_resource, content, categories)
      end
    end

    def categories_for(tx_resource)
      resource = project.api.get_resource(*tx_resource.slugs)
      deserialize_categories(Array(resource['categories']))
    end
  end
end
