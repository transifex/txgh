require 'txgh'
require 'txgh-server'

module TxghQueue
  class Job
    include TxghServer::Webhooks::Github
    include TxghServer::ResponseHelpers

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def process(payload)
      Supervisor.supervise do
        config = config_from(payload)
        project = config.transifex_project
        repo = config.github_repo

        case payload.fetch('event')
          when 'push'
            handle_push(project, repo, payload)
          when 'delete'
            handle_delete(project, repo, payload)
          else
            handle_unexpected
        end
      end
    end

    private

    def config_from(payload)
      Txgh::Config::KeyManager.config_from_repo(payload.fetch('repo_name'))
    end

    def handle_push(project, repo, payload)
      attributes = PushAttributes.new(payload)
      PushHandler.new(project, repo, logger, attributes).execute
    end

    def handle_delete(project, repo, payload)
      attributes = DeleteAttributes.new(payload)
      DeleteHandler.new(project, repo, logger, attributes).execute
    end

    def handle_unexpected
      respond_with_error(400, 'Unexpected event type')
    end
  end
end
