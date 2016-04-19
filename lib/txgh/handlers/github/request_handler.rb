require 'json'

module Txgh
  module Handlers
    module Github
      class RequestHandler
        class << self

          include ResponseHelpers

          def handle_request(request, logger)
            case request.env['HTTP_X_GITHUB_EVENT']
              when 'push'
                handle_push(request, logger)
              when 'delete'
                handle_delete(request, logger)
              when 'ping'
                handle_ping(request, logger)
              else
                handle_unexpected
            end
          end

          private

          def handle_push(request, logger)
            klass = Txgh::Handlers::Github::PushHandler
            new(request, logger).handle(klass)
          end

          def handle_delete(request, logger)
            klass = Txgh::Handlers::Github::DeleteHandler
            new(request, logger).handle(klass)
          end

          def handle_ping(request, logger)
            klass = Txgh::Handlers::Github::PingHandler
            new(request, logger).handle(klass)
          end

          def handle_unexpected
            respond_with_error(400, 'Unexpected event type')
          end

        end

        include ResponseHelpers

        attr_reader :request, :logger

        def initialize(request, logger)
          @request = request
          @logger = logger
        end

        def handle(klass)
          handle_safely do
            handler = klass.new(
              project: config.transifex_project,
              repo: config.github_repo,
              payload: payload,
              logger: logger
            )

            handler.execute
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

        def payload
          @payload ||= if request.params[:payload]
            JSON.parse(request.params[:payload])
          else
            JSON.parse(request.body.read)
          end
        end

        def github_repo_name
          payload['repository']['full_name']
        end

        def config
          @config ||= Txgh::Config::KeyManager.config_from_repo(github_repo_name)
        end

        def repo
          config.github_repo
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
