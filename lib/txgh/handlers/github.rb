module Txgh
  module Handlers
    module Github
      autoload :PushHandler,    'txgh/handlers/github/push_handler'
      autoload :RequestHandler, 'txgh/handlers/github/request_handler'
    end
  end
end
