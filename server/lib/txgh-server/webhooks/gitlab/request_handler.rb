require 'json'

module TxghServer
  module Webhooks
    module Gitlab
      class RequestHandler < TxghServer::Webhooks::Github::RequestHandler
        def handle_request
          handle_safely do
            if gitlab_event == 'Push Hook'
              if payload.fetch('after') == '0000000000000000000000000000000000000000'
                DeleteHandler.new(project, repo, logger, DeleteAttributes.from_webhook_payload(payload)).execute
              else
                PushHandler.new(project, repo, logger, PushAttributes.from_webhook_payload(payload)).execute
              end
            else
              respond_with_error(400, 'Unexpected event type')
            end
          end
        end

        private

        def gitlab_event
          request.env['HTTP_X_GITLAB_EVENT']
        end

        def git_repo_name
          payload.fetch('project', {})['path_with_namespace']
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
