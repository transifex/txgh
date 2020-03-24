require 'json'

module TxghServer
  module Webhooks
    module Git
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
          raise NotImplementedError
        end

        private

        def attributes
          raise NotImplementedError
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

        def git_repo_name
          raise NotImplementedError
        end

        def config
          @config ||= Txgh::Config::KeyManager.config_from_repo(git_repo_name)
        end

        def repo
          config.git_repo
        end

        def project
          config.transifex_project
        end

        def authentic_request?
          raise NotImplementedError
        end
      end
    end
  end
end
