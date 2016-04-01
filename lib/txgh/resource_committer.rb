module Txgh
  class ResourceCommitter
    attr_reader :project, :repo, :logger

    def initialize(project, repo, logger = nil)
      @project = project
      @repo = repo
      @logger = logger || Logger.new(STDOUT)
    end

    def commit_resource(tx_resource, branch, language)
      return if prevent_commit_on?(branch)

      unless language == tx_resource.source_lang
        file_name, translations = download(tx_resource, branch, language)
        repo.api.commit(repo.name, branch, { file_name => translations })
      end
    end

    private

    def download(tx_resource, branch, language)
      downloader = ResourceDownloader.new(
        project, repo, branch, {
          languages: [language], resources: [tx_resource]
        }
      )

      downloader.first
    end

    def prevent_commit_on?(branch)
      project.protected_branches.include?(branch)
    end
  end
end
