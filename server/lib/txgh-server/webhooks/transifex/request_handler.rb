require 'uri'

module TxghServer
  module Webhooks
    module Transifex
      class RequestHandler
        class << self
          def handle_request(request, logger)
            new(request, logger).handle_request
          end
        end

        include ResponseHelpers

        attr_reader :request, :logger

        def initialize(request, logger)
          @request = request
          @logger = logger
        end

        def handle_request
          handle_safely do
            handler = TxghServer::Webhooks::Transifex::HookHandler.new(
              project: config.transifex_project,
              repo: config.github_repo,
              resource_slug: payload[:resource],
              language: payload[:language],
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

        def authentic_request?
          if project.webhook_protected?
            TransifexRequestAuth.authentic_request?(
              request, project.webhook_secret
            )
          else
            true
          end
        end

        def project
          config.transifex_project
        end

        def config
          @config ||= Txgh::Config::KeyManager.config_from_project(payload[:project])
        end

        def payload
          @payload ||= begin
            request.body.rewind

            Txgh::Utils.deep_symbolize_keys(
              Hash[URI.decode_www_form(request.body.read)]
            )
          end
        end

      end
    end
  end
end
