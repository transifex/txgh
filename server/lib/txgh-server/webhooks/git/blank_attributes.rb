module TxghServer
  module Webhooks
    module Git
      class BlankAttributes
        class << self
          def from_webhook_payload(payload)
            new
          end
        end

        def initialize(options = {})
        end

        def to_h
          {}
        end
      end
    end
  end
end
