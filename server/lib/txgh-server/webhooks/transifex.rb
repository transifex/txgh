module TxghServer
  module Webhooks
    module Transifex
      autoload :HookHandler,    'txgh-server/webhooks/transifex/hook_handler'
      autoload :RequestHandler, 'txgh-server/webhooks/transifex/request_handler'
    end
  end
end
