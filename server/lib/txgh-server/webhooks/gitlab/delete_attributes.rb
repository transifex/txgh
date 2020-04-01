module TxghServer
  module Webhooks
    module Gitlab
      class DeleteAttributes < TxghServer::Webhooks::Git::DeleteAttributes
        class << self
          def repo_name(payload)
            payload.fetch('project', {})['path_with_namespace']
          end

          def ref_type(_payload)
            'branch'
          end
        end
      end
    end
  end
end
