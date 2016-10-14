module TxghQueue
  module Webhooks
    autoload :Github,    'txgh-queue/webhooks/github'
    autoload :Transifex, 'txgh-queue/webhooks/transifex'
  end
end
