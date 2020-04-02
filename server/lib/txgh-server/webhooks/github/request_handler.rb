require 'json'

module TxghServer
  module Webhooks
    module Github
      class RequestHandler < TxghServer::Webhooks::Git::RequestHandler
        def handle_request
          handle_safely do
            case github_event
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
          case github_event
            when 'push'
              PushAttributes.from_webhook_payload(payload)
            when 'delete'
              DeleteAttributes.from_webhook_payload(payload)
            else
              BlankAttributes.from_webhook_payload(payload)
          end
        end

        def github_event
          request.env['HTTP_X_GITHUB_EVENT']
        end

        def git_repo_name
          payload.fetch('repository', {})['full_name']
        end

        def project
          config.transifex_project
        end

        def authentic_request?
          if repo.webhook_protected?
            GithubRequestAuth.authentic_request?(
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
