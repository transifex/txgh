require 'uri'

module Txgh
  module Handlers
    module Transifex
      class RequestHandler
        class << self

          def handle_request(request, logger)
            payload = Hash[URI.decode_www_form(request.body.read)]
            config = Txgh::KeyManager.config_from_project(payload['project'])

            if authentic_request?(config.transifex_project, request)
              handler = Txgh::Handlers::Transifex::HookHandler.new(
                project: config.transifex_project,
                repo: config.github_repo,
                resource_slug: payload['resource'],
                language: payload['language'],
                logger: logger
              )

              handler.execute
            else
              [401, error('Unauthorized')]
            end
          rescue => e
            [500, error("Internal server error: #{e.message}")]
          end

          private

          def authentic_request?(project, request)
            if project.webhook_protected?
              TransifexRequestAuth.authentic_request?(
                request, project.webhook_secret
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
