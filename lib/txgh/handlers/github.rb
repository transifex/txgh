module Txgh
  module Handlers
    module Github
      autoload :DeleteHandler,  'txgh/handlers/github/delete_handler'
      autoload :Handler,        'txgh/handlers/github/handler'
      autoload :PingHandler,    'txgh/handlers/github/ping_handler'
      autoload :PushHandler,    'txgh/handlers/github/push_handler'
      autoload :RequestHandler, 'txgh/handlers/github/request_handler'
    end
  end
end
