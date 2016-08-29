module Txgh
  class Pusher
    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch = nil)
      @project = project
      @repo = repo
      @branch = branch
    end

    def push
      tx_config.resources.each do |tx_resource|
        if repo.process_all_branches?
          tx_resource = Txgh::TxBranchResource.new(tx_resource, branch)
        end

        push_resource(tx_resource)
      end
    end

    def push_resource(tx_resource)
      ref = repo.api.get_ref(branch || repo.branch)
      updater.update_resource(tx_resource, ref[:object][:sha])
    end

    def push_slug(resource_slug)
      push_resource(tx_config.resource(resource_slug, branch))
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
