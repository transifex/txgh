require "logger"

module Txgh
  class TxLogger
    def self.logger
      @_logger ||= Logger.new(STDOUT).tap do |logger|
        logger.level = Logger::INFO
        logger.datetime_format = '%a %d-%m-%Y %H%M '
      end
    end
  end
end
