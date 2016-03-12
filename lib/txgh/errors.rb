module Txgh
  class TxghError < StandardError; end
  class TxghInternalError < TxghError; end

  class TransifexApiError < StandardError; end
  class TransifexUnauthorizedError < StandardError; end
  class ConfigNotFoundError < StandardError; end
end
