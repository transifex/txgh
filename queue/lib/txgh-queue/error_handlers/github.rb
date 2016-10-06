require 'octokit'

module TxghQueue
  module ErrorHandlers
    class Github
      ERROR_CLASSES = {
        Octokit::AbuseDetected           => Status.fail,
        Octokit::BadGateway              => Status.retry_without_delay,
        Octokit::BadRequest              => Status.fail,
        Octokit::ClientError             => Status.fail,
        Octokit::Conflict                => Status.fail,
        Octokit::Forbidden               => Status.fail,
        Octokit::InternalServerError     => Status.retry_with_delay,
        Octokit::MethodNotAllowed        => Status.fail,
        Octokit::NotAcceptable           => Status.fail,
        Octokit::NotFound                => Status.fail,
        Octokit::NotImplemented          => Status.fail,
        Octokit::OneTimePasswordRequired => Status.fail,
        Octokit::RepositoryUnavailable   => Status.retry_with_delay,
        Octokit::ServerError             => Status.retry_with_delay,
        Octokit::ServiceUnavailable      => Status.retry_with_delay,
        Octokit::TooManyLoginAttempts    => Status.retry_with_delay,
        Octokit::TooManyRequests         => Status.retry_with_delay,
        Octokit::Unauthorized            => Status.fail,
        Octokit::UnprocessableEntity     => Status.fail,
        Octokit::UnsupportedMediaType    => Status.fail,
        Octokit::UnverifiedEmail         => Status.fail
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
