require 'logger'

module Txgh
  class ResourceUpdater
    include Txgh::CategorySupport

    attr_reader :project, :repo, :logger

    def initialize(project, repo, logger = nil)
      @project = project
      @repo = repo
      @logger = logger || Logger.new(STDOUT)
    end

    def update_resource(tx_resource, categories = {})
      # don't process the resource unless the project slugs are the same
      return unless tx_resource.project_slug == project.name
      branch = tx_resource.branch || repo.diff_point
      file = repo.api.download(tx_resource.source_file, branch)

      if repo.upload_diffs? && tx_resource.has_branch?
        upload_diff(tx_resource, file, categories)
      else
        upload_whole(tx_resource, file, categories)
      end

      fire_event_for(tx_resource, file)
    end

    private

    def fire_event_for(tx_resource, file)
      Txgh.events.publish(
        'transifex.resource.updated', {
          project: project, repo: repo, resource: tx_resource, sha: file[:sha]
        }
      )
    end

    def upload_whole(tx_resource, file, categories)
      if repo.process_all_branches?
        upload_by_branch(tx_resource, file[:content], categories)
      else
        upload(tx_resource, file[:content])
      end
    end

    def upload_diff(tx_resource, file, categories)
      # if uploading to master (i.e. the diff point), then upload the full resource
      if Utils.branches_equal?(tx_resource.branch, repo.diff_point)
        upload_whole(tx_resource, file, categories)
      else
        if content = diff_content(tx_resource, file)
          upload_by_branch(tx_resource, content, categories)
        end
      end
    end

    def diff_content(tx_resource, file)
      diff = head_content(tx_resource, file).diff(
        diff_point_content(tx_resource, file)
      )

      diff.to_s unless diff.empty?
    end

    def head_content(tx_resource, file)
      ResourceContents.from_string(tx_resource, file[:content])
    end

    def diff_point_content(tx_resource, file)
      raw_content = repo.api.download(file[:path], repo.diff_point)
      ResourceContents.from_string(tx_resource, raw_content)
    end

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
