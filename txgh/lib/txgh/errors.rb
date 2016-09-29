module Txgh
  class TxghError < StandardError; end
  class TxghInternalError < TxghError; end

  class TransifexApiError < StandardError
    attr_reader :status_code

    def initialize(message, status_code)
      super(message)
      @status_code = status_code
    end
  end

  class TransifexNotFoundError < TransifexApiError
    def initialize(message = 'Not found')
      super(message, 404)
    end
  end

  class TransifexUnauthorizedError < TransifexApiError
    def initialize(message = 'Unauthorized')
      super(message, 401)
    end
  end

  class InvalidProviderError < StandardError; end

  class ConfigNotFoundError < StandardError; end
  class ProjectConfigNotFoundError < ConfigNotFoundError; end
  class RepoConfigNotFoundError < ConfigNotFoundError; end
  class GitConfigNotFoundError < ConfigNotFoundError; end
end
