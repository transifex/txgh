require 'json'

module TxghServer
  module Webhooks
    module Gitlab
      class RequestHandler < TxghServer::Webhooks::Github::RequestHandler
        def handle_request
          handle_safely do
            case gitlab_event
              when 'push'
                PushHandler.new(project, repo, logger, attributes).execute
              when 'delete'
                DeleteHandler.new(project, repo, logger, attributes).execute
              when 'ping'
                PingHandler.new(logger).execute
              else
                respond_with_error(400, 'Unexpected event type')
            end
          end
        end

        private

        def attributes
          case gitlab_event
            when 'push'
              PushAttributes.from_webhook_payload(payload)
            when 'delete'
              DeleteAttributes.from_webhook_payload(payload)
            else
              BlankAttributes.from_webhook_payload(payload)
          end
        end

        def gitlab_event
          request.env['HTTP_X_GITLAB_EVENT']
        end

        def git_repo_name
          payload.fetch('repository', {})['name']
        end

        def config
          @config ||= Txgh::Config::KeyManager.config_from_repo(git_repo_name)
        end

        def repo
          config.git_repo
        end

        def authentic_request?
          if repo.webhook_protected?
            GitlabRequestAuth.authentic_request?(
              request, repo.webhook_secret
            )
          else
            true
          end
        end
      end
    end
  end
end
