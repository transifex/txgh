module Txgh
  module Config
    module Providers
      class FileProvider
        SCHEME = 'file'

        class << self
          def supports?(scheme)
            scheme == SCHEME
          end

          def load(payload, parser, options = {})
            parser.load_file(payload)
          end

          def scheme
            SCHEME
          end
        end
      end
    end
  end
end
