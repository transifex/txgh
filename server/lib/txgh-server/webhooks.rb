module TxghServer
  module Webhooks
    autoload :Github,    'txgh-server/webhooks/github'
    autoload :Transifex, 'txgh-server/webhooks/transifex'
  end
end
