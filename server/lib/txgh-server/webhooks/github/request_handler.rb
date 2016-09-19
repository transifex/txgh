require 'json'

module TxghServer
  module Webhooks
    module Github
      class RequestHandler
        include ResponseHelpers

        class << self
          def handle_request(request, logger)
            new(request, logger).handle_request
          end
        end

        attr_reader :request, :logger

        def initialize(request, logger)
          @request = request
          @logger = logger
        end

        def handle_request
          handle_safely do
            case request.env['HTTP_X_GITHUB_EVENT']
              when 'push'
                handle_push
              when 'delete'
                handle_delete
              when 'ping'
                handle_ping
              else
                handle_unexpected
            end
          end
        end

        private

        def handle_safely
          if authentic_request?
            yield
          else
            respond_with_error(401, 'Unauthorized')
          end
        rescue => e
          respond_with_error(500, "Internal server error: #{e.message}", e)
        end

        def handle_push
          attributes = PushAttributes.from_webhook_payload(payload)
          PushHandler.new(project, repo, logger, attributes).execute
        end

        def handle_delete
          attributes = DeleteAttributes.from_webhook_payload(payload)
          DeleteHandler.new(project, repo, logger, attributes).execute
        end

        def handle_ping
          PingHandler.new(logger).execute
        end

        def handle_unexpected
          respond_with_error(400, 'Unexpected event type')
        end

        def payload
          @payload ||= begin
            if request.params[:payload]
              JSON.parse(request.params[:payload])
            else
              JSON.parse(request.body.read)
            end
          rescue JSON::ParserError
            {}
          end
        end

        def github_repo_name
          payload.fetch('repository', {})['full_name']
        end

        def config
          @config ||= Txgh::Config::KeyManager.config_from_repo(github_repo_name)
        end

        def repo
          config.github_repo
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
