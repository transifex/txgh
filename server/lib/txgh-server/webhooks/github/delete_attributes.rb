module TxghServer
  module Webhooks
    module Github
      class DeleteAttributes < TxghServer::Webhooks::Git::DeleteAttributes
        class << self
          def repo_name(payload)
            payload.fetch('repository').fetch('full_name')
          end

          def ref_type(payload)
            payload.fetch('ref_type')
          end
        end
      end
    end
  end
end
