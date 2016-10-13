require 'json'
require 'txgh-queue'

module TxghServer
  module Webhooks
    module Github
      class RequestHandler
        include ResponseHelpers

        class << self
          def handle_request(request, logger)
            new(request, logger).handle_request
          end

          def enqueue_request(request, logger)
            new(request, logger).enqueue
          end
        end

        attr_reader :request, :logger

        def initialize(request, logger)
          @request = request
          @logger = logger
        end

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

        def enqueue
          handle_safely do
            case github_event
              when 'push', 'delete'
                txgh_event = "github.#{github_event}"

                result = TxghQueue::Config.backend
                  .producer_for(txgh_event, logger)
                  .enqueue(attributes.to_h.merge(txgh_event: txgh_event))

                respond_with(202, result.to_json)
              when 'ping'
                PingHandler.new(logger).execute
              else
                respond_with_error(400, "Event '#{github_event}' cannot be enqueued")
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

        def github_event
          request.env['HTTP_X_GITHUB_EVENT']
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
