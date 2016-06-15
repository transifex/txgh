require 'logger'

module Txgh
  class TxLogger
    def self.logger
      log_file_path = Pathname(File::dirname(__FILE__)).join("../../log/#{ENV['RACK_ENV']}.log")
      @_logger ||= Logger.new(log_file_path).tap do |logger|
        logger.level = Logger::DEBUG
        logger.datetime_format = '%a %d-%m-%Y %H%M '
      end
    end
  end
end
