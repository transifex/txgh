module TxghServer
  module Webhooks
    autoload :Git,       'txgh-server/webhooks/git'
    autoload :Github,    'txgh-server/webhooks/github'
    autoload :Gitlab,    'txgh-server/webhooks/gitlab'
    autoload :Transifex, 'txgh-server/webhooks/transifex'
  end
end
