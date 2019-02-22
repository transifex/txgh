require 'erb'

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
            parser.load(ERB.new(payload).result(binding))
          end

          def scheme
            SCHEME
          end
        end
      end
    end
  end
end
