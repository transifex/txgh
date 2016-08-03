module TxghServer
  module Triggers
    autoload :Handler,     'txgh-server/triggers/handler'
    autoload :PullHandler, 'txgh-server/triggers/pull_handler'
    autoload :PushHandler, 'txgh-server/triggers/push_handler'
  end
end
