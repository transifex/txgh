module Txgh
  module Config
    module Providers
      class RawProvider
        SCHEME = 'raw'

        class << self
          def supports?(scheme)
            scheme == SCHEME
          end

          def load(payload, parser, options = {})
            parser.load(payload)
          end
        end
      end
    end
  end
end
