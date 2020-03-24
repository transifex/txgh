require 'gitlab'

module TxghQueue
  module ErrorHandlers
    class Gitlab
      ERROR_CLASSES = {
        ::Gitlab::Error::BadGateway          => Status.retry_without_delay,
        ::Gitlab::Error::BadRequest          => Status.fail,
        ::Gitlab::Error::Conflict            => Status.fail,
        ::Gitlab::Error::Forbidden           => Status.fail,
        ::Gitlab::Error::InternalServerError => Status.retry_with_delay,
        ::Gitlab::Error::MethodNotAllowed    => Status.fail,
        ::Gitlab::Error::NotAcceptable       => Status.fail,
        ::Gitlab::Error::NotFound            => Status.fail,
        ::Gitlab::Error::ServiceUnavailable  => Status.retry_with_delay,
        ::Gitlab::Error::TooManyRequests     => Status.retry_with_delay,
        ::Gitlab::Error::Unauthorized        => Status.fail,
        ::Gitlab::Error::Unprocessable       => Status.fail
      }

      class << self
        def can_handle?(error_or_response)
          error_or_response.is_a?(Octokit::Error)
        end

        def status_for(error)
          ERROR_CLASSES.fetch(error.class) { handle_other(error) }
        end

        private

        def handle_other(error)
          Status.fail
        end
      end
    end
  end
end
