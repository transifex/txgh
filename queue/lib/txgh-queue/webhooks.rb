module TxghQueue
  module Webhooks
    autoload :Github,    'txgh-queue/webhooks/github'
    autoload :Gitlab,    'txgh-queue/webhooks/gitlab'
    autoload :Transifex, 'txgh-queue/webhooks/transifex'
  end
end
