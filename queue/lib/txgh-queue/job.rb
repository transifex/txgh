require 'txgh'
require 'txgh-server'

module TxghQueue
  class Job
    Github = TxghServer::Webhooks::Github
    Gitlab = TxghServer::Webhooks::Gitlab
    Transifex = TxghServer::Webhooks::Transifex
    include TxghServer::ResponseHelpers

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def process(payload)
      Supervisor.supervise do
        case payload.fetch('txgh_event')
          when 'github.push', 'github.delete', 'gitlab.push', 'gitlab.delete', 'transifex.hook'
            handle_expected(payload)
          else
            handle_unexpected
        end
      end
    end

    private

    def handle_expected(payload)
      config = config_from(payload)
      project = config.transifex_project
      repo = config.git_repo

      case payload.fetch('txgh_event')
        when 'github.push'
          handle_github_push(project, repo, payload)
        when 'github.delete'
          handle_github_delete(project, repo, payload)
        when 'gitlab.push'
          handle_gitlab_push(project, repo, payload)
        when 'gitlab.delete'
          handle_gitlab_delete(project, repo, payload)
        when 'transifex.hook'
          handle_transifex_hook(project, repo, payload)
      end
    end

    def config_from(payload)
      case payload.fetch('txgh_event')
        when 'github.push', 'github.delete', 'gitlab.push', 'gitlab.delete'
          Txgh::Config::KeyManager.config_from_repo(payload.fetch('repo_name'))
        when 'transifex.hook'
          Txgh::Config::KeyManager.config_from_project(payload.fetch('project'))
      end
    end

    def handle_github_push(project, repo, payload)
      attributes = Github::PushAttributes.new(payload)
      handler = Github::PushHandler.new(project, repo, logger, attributes)
      execute(handler)
    end

    def handle_github_delete(project, repo, payload)
      attributes = Github::DeleteAttributes.new(payload)
      handler = Github::DeleteHandler.new(project, repo, logger, attributes)
      execute(handler)
    end

    def handle_gitlab_push(project, repo, payload)
      attributes = TxghServer::Webhooks::Gitlab::PushAttributes.new(payload)
      handler = TxghServer::Webhooks::Gitlab::PushHandler.new(project, repo, logger, attributes)
      execute(handler)
    end

    def handle_gitlab_delete(project, repo, payload)
      attributes = TxghServer::Webhooks::Gitlab::DeleteAttributes.new(payload)
      handler = TxghServer::Webhooks::Gitlab::DeleteHandler.new(project, repo, logger, attributes)
      execute(handler)
    end

    def handle_transifex_hook(project, repo, payload)
      handler = Transifex::HookHandler.new(
        project: project,
        repo: repo,
        resource_slug: payload['resource'],
        language: payload['language'],
        logger: logger
      )

      execute(handler)
    end

    def execute(handler)
      if TxghQueue::Config.processing_enabled?
        handler.execute
      else
        respond_with(200, 'Ok')
      end
    end

    def handle_unexpected
      respond_with_error(400, 'Unexpected event type')
    end
  end
end
