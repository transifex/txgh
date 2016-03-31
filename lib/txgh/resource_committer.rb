require 'logger'

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
        logger.info('request language matches resource')
        downloader = ResourceDownloader.new(project, repo, branch, [language])
      end
    end

    private

    def commit_whole(tx_resource, branch, language)
      logger.info("make github commit for branch: #{branch}")
      translations = project.api.download(tx_resource, language)
      path = translation_path(tx_resource, language)

      repo.api.commit(
        repo.name, branch, translation_path, translations
      )
    end

    def commit_diff(tx_resource, branch, language)
    end

    def translation_path(tx_resource, language)
      if tx_resource.lang_map(language) != language
        logger.info('request language is in lang_map and is not in request')
        tx_resource.translation_path(tx_resource.lang_map(language))
      else
        logger.info('request language is in lang_map and is in request or is nil')
        tx_resource.translation_path(tx_resource.lang_map(language))
      end
    end

    def prevent_commit_on?(branch)
      project.protected_branches.include?(branch)
    end
  end
end
