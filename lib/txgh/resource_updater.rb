module Txgh
  class ResourceUpdater
    include Txgh::CategorySupport

    attr_reader :project, :repo, :logger, :payload

    def initialize(project, repo, logger, payload)
      @project = project
      @repo = repo
      @logger = logger
      @payload = payload  # @TODO: remove
    end

    # For each modified resource, get its content and update the content
    # in Transifex.
    def update_resources(resources)
      Array(resources).each do |tx_resource, commit_sha|
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
              upload_by_branch(tx_resource, content)
            else
              upload(tx_resource, content)
            end

            logger.info "updated tx_resource: #{tx_resource.inspect}"
          end
        end
      end
    end

    private

    def upload(tx_resource, content)
      project.api.create_or_update(tx_resource, content)
    end

    def upload_by_branch(tx_resource, content)
      resource_exists = project.api.resource_exists?(tx_resource)

      categories = if resource_exists
        resource = project.api.get_resource(*tx_resource.slugs)
        deserialize_categories(Array(resource['categories']))
      else
        {}
      end

      categories['branch'] ||= tx_resource.branch
      categories['author'] ||= escape_category(
        payload['head_commit']['committer']['name']
      )

      categories = serialize_categories(categories)

      if resource_exists
        project.api.update_details(tx_resource, categories: categories)
        project.api.update_content(tx_resource, content)
      else
        project.api.create(tx_resource, content, categories)
      end
    end
  end
end
