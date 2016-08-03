module TxghServer
  module Webhooks
    module Github
      # Handles github's ping event, which is a test event fired whenever a new
      # webhook is set up.
      class PingHandler
        include ResponseHelpers

        def initialize(options = {})
        end

        def execute
          respond_with(200, {})
        end
      end
    end
  end
end
