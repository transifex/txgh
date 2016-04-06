module Txgh
  class TxghError < StandardError; end
  class TxghInternalError < TxghError; end

  class TransifexApiError < StandardError; end
  class TransifexNotFoundError < TransifexApiError; end
  class TransifexUnauthorizedError < TransifexApiError; end
  class ConfigNotFoundError < StandardError; end
end
