require 'json'

module TxghServer
  module Webhooks
    module Gitlab
      class RequestHandler < TxghServer::Webhooks::Github::RequestHandler
        def handle_request
          handle_safely do
            if gitlab_event == 'Push Hook'
              if delete_event?
                DeleteHandler.new(project, repo, logger, attributes).execute
              else
                PushHandler.new(project, repo, logger, attributes).execute
              end
            else
              respond_with_error(400, 'Unexpected event type')
            end
          end
        end

        private

        def attributes
          unless gitlab_event == 'Push Hook'
            return BlankAttributes.from_webhook_payload(payload)
          end

          if delete_event?
            return DeleteAttributes.from_webhook_payload(payload)
          end

          PushAttributes.from_webhook_payload(payload)
        end

        def gitlab_event
          request.env['HTTP_X_GITLAB_EVENT']
        end

        def delete_event?
          payload.fetch('after') == '0000000000000000000000000000000000000000'
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
