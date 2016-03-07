module Txgh
  module Handlers
    module Triggers
      autoload :Handler,     'txgh/handlers/triggers/handler'
      autoload :PullHandler, 'txgh/handlers/triggers/pull_handler'
      autoload :PushHandler, 'txgh/handlers/triggers/push_handler'
    end
  end
end
