module Txgh
  class Puller
    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch = nil)
      @project = project
      @repo = repo
      @branch = branch
    end

    def pull
      tx_config.resources.each do |tx_resource|
        if repo.process_all_branches?
          tx_resource = Txgh::TxBranchResource.new(tx_resource, branch)
        end

        pull_resource(tx_resource)
      end
    end

    def pull_resource(tx_resource)
      each_language do |language_code|
        committer.commit_resource(tx_resource, branch, language_code)
      end
    end

    def pull_slug(resource_slug)
      pull_resource(tx_config.resource(resource_slug, branch))
    end

    private

    def committer
      @committer ||= Txgh::ResourceCommitter.new(project, repo)
    end

    def each_language
      return to_enum(__method__) unless block_given?

      languages.each do |language|
        language_code = language['language_code']

        if project.supported_language?(language_code)
          yield language_code
        end
      end
    end

    def languages
      @languages ||= project.api.get_languages(project.name)
    end

    def tx_config
      @tx_config ||= Txgh::Config::TxManager.tx_config(project, repo, branch)
    end
  end
end
