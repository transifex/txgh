module TxghQueue
  module ErrorHandlers
    autoload :Github,         'txgh-queue/error_handlers/github'
    autoload :ServerResponse, 'txgh-queue/error_handlers/server_response'
    autoload :StandardErrors, 'txgh-queue/error_handlers/standard_errors'
    autoload :Transifex,      'txgh-queue/error_handlers/transifex'
    autoload :TxghErrors,     'txgh-queue/error_handlers/txgh_errors'
  end
end
