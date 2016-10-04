module Txgh
  class Pusher
    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch = nil)
      @project = project
      @repo = repo
      @branch = branch
    end

    def push(&block)
      existing_resources = project.api.get_resources(project.name)
      slugs = existing_resources.map { |resource| resource['slug'] }

      resources = tx_config.resources.each_with_object([]) do |tx_resource, ret|
        if repo.process_all_branches?
          tx_resource = Txgh::TxBranchResource.new(tx_resource, branch)
        end

        next unless slugs.include?(tx_resource.resource_slug)
        ret << tx_resource
      end

      push_resources(resources, &block)
    end

    def push_resources(tx_resources, &block)
      tx_resources.each do |tx_resource|
        categories = block_given? ? yield(tx_resource) : {}
        push_resource(tx_resource, categories)
      end
    end

    def push_resource(tx_resource, categories = {})
      updater.update_resource(tx_resource, categories)
    end

    def push_slug(resource_slug, categories = {})
      push_resource(tx_config.resource(resource_slug, branch), categories)
    end

    private

    def updater
      @updater ||= Txgh::ResourceUpdater.new(project, repo)
    end

    def tx_config
      @tx_config ||= Txgh::Config::TxManager.tx_config(project, repo, branch)
    end
  end
end
