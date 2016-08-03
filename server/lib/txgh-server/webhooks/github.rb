module TxghServer
  module Webhooks
    module Github
      autoload :DeleteHandler,  'txgh-server/webhooks/github/delete_handler'
      autoload :Handler,        'txgh-server/webhooks/github/handler'
      autoload :PingHandler,    'txgh-server/webhooks/github/ping_handler'
      autoload :PushHandler,    'txgh-server/webhooks/github/push_handler'
      autoload :RequestHandler, 'txgh-server/webhooks/github/request_handler'
    end
  end
end
