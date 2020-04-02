module TxghServer
  module Webhooks
    module Git
      autoload :BlankAttributes,  'txgh-server/webhooks/git/blank_attributes'
      autoload :DeleteAttributes, 'txgh-server/webhooks/git/delete_attributes'
      autoload :DeleteHandler,    'txgh-server/webhooks/git/delete_handler'
      autoload :Handler,          'txgh-server/webhooks/git/handler'
      autoload :PingHandler,      'txgh-server/webhooks/git/ping_handler'
      autoload :PushHandler,      'txgh-server/webhooks/git/push_handler'
      autoload :PushAttributes,   'txgh-server/webhooks/git/push_attributes'
      autoload :RequestHandler,   'txgh-server/webhooks/git/request_handler'
      autoload :StatusUpdater,    'txgh-server/webhooks/git/status_updater'
    end
  end
end
