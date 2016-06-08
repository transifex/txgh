module Txgh
  class TxghError < StandardError; end
  class TxghInternalError < TxghError; end

  class TransifexApiError < StandardError; end
  class TransifexNotFoundError < TransifexApiError; end
  class TransifexUnauthorizedError < TransifexApiError; end

  class InvalidProviderError < StandardError; end

  class ConfigNotFoundError < StandardError; end
  class ProjectConfigNotFoundError < ConfigNotFoundError; end
  class RepoConfigNotFoundError < ConfigNotFoundError; end
  class GitConfigNotFoundError < ConfigNotFoundError; end
end
