module Txgh
  module Handlers
    autoload :Github,    'txgh/handlers/github'
    autoload :Response,  'txgh/handlers/response'
    autoload :Transifex, 'txgh/handlers/transifex'
    autoload :Triggers,  'txgh/handlers/triggers'
  end
end
