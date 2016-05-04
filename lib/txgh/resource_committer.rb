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

        if translations
          repo.api.commit(repo.name, branch, { file_name => translations })
          fire_event_for(tx_resource, branch, language)
        end
      end
    end

    private

    def fire_event_for(tx_resource, branch, language)
      head = repo.api.get_ref(repo.name, branch)
      sha = head[:object][:sha]

      Txgh.events.publish(
        'github.resource.committed', {
          project: project, repo: repo, resource: tx_resource, sha: sha,
          language: language
        }
      )
    end

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
