require 'json'

module Txgh
  module Handlers
    module Github
      class RequestHandler
        class << self

          def handle_request(request, logger)
            case request.env['HTTP_X_GITHUB_EVENT']
              when 'push'
                handle_push(request, logger)
              when 'delete'
                handle_delete(request, logger)
              else
                [400, error('Unexpected event type')]
            end
          end

          private

          def handle_push(request, logger)
            payload = get_payload_from(request)
            github_repo_name = "#{payload['repository']['owner']['name']}/#{payload['repository']['name']}"
            config = Txgh::KeyManager.config_from_repo(github_repo_name)

            if authentic_request?(config.github_repo, request)
              handler = Txgh::Handlers::Github::PushHandler.new(
                project: config.transifex_project,
                repo: config.github_repo,
                payload: payload,
                logger: logger
              )

              handler.execute
            else
              [401, error('Unauthorized')]
            end
          rescue => e
            [500, error("Internal server error: #{e.message}")]
          end

          def handle_delete(request)
          end

          def get_payload_from(request)
            if request.params[:payload]
              JSON.parse(request.params[:payload])
            else
              JSON.parse(request.body.read)
            end
          end

          def authentic_request?(repo, request)
            if repo.webhook_protected?
              GithubRequestAuth.authentic_request?(
                request, repo.webhook_secret
              )
            else
              true
            end
          end

          def error(msg)
            [{ error: msg }]
          end

        end
      end
    end
  end
end
