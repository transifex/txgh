module TxghServer
  module Webhooks
    module Github
      # Handles github's ping event, which is a test event fired whenever a new
      # webhook is set up.
      class PingHandler < TxghServer::Webhooks::Git::PingHandler
      end
    end
  end
end
