module Txgh
  module Handlers
    autoload :Github,               'txgh/handlers/github'
    autoload :TransifexHookHandler, 'txgh/handlers/transifex_hook_handler'
    autoload :Response,             'txgh/handlers/response'
  end
end
