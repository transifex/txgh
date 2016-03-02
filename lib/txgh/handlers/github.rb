module Txgh
  module Handlers
    module Github
      autoload :DeleteHandler,  'txgh/handlers/github/delete_handler'
      autoload :PushHandler,    'txgh/handlers/github/push_handler'
      autoload :RequestHandler, 'txgh/handlers/github/request_handler'
    end
  end
end
