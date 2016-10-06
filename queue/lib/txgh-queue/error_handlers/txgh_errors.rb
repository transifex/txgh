require 'txgh'

module TxghQueue
  module ErrorHandlers
    class TxghErrors
      ERROR_CLASSES = {
        Txgh::ConfigNotFoundError        => Status.fail,
        Txgh::GitConfigNotFoundError     => Status.fail,
        Txgh::InvalidProviderError       => Status.fail,
        Txgh::ProjectConfigNotFoundError => Status.fail,
        Txgh::RepoConfigNotFoundError    => Status.fail,
        Txgh::TxghError                  => Status.fail,
        Txgh::TxghInternalError          => Status.fail
      }

      class << self
        def can_handle?(error_or_response)
          ERROR_CLASSES.any? { |klass, _| error_or_response.class <= klass }
        end

        def status_for(error)
          ERROR_CLASSES[error.class]
        end
      end
    end
  end
end
