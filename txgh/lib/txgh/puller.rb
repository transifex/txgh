module Txgh
  class Puller
    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch = nil)
      @project = project
      @repo = repo
      @branch = branch
    end

    def pull
      existing_resources = project.api.get_resources(project.name)
      slugs = existing_resources.map { |resource| resource['slug'] }

      resources = tx_config.resources.each_with_object([]) do |tx_resource, ret|
        if repo.process_all_branches?
          tx_resource = Txgh::TxBranchResource.new(tx_resource, branch)
        end

        next unless slugs.include?(tx_resource.resource_slug)
        ret << tx_resource
      end

      pull_resources(resources)
    end

    def pull_resources(tx_resources, languages = nil)
      tx_resources.each do |tx_resource|
        pull_resource(tx_resource, languages)
      end
    end

    def pull_resource(tx_resource, languages = nil)
      (languages || project.languages).each do |language|
        committer.commit_resource(tx_resource, branch, language)
      end
    end

    def pull_slug(resource_slug, languages = nil)
      pull_resource(tx_config.resource(resource_slug, branch), languages)
    end

    private

    def committer
      @committer ||= Txgh::ResourceCommitter.new(project, repo)
    end

    def languages
      @languages ||= project.api.get_languages(project.name)
    end

    def tx_config
      @tx_config ||= Txgh::Config::TxManager.tx_config(project, repo, branch)
    end
  end
end
