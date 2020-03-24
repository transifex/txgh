module TxghServer
  module Webhooks
    module Gitlab
      class PushAttributes < TxghServer::Webhooks::Git::PushAttributes
        class << self
          def repo_name(payload)
            payload.fetch('repository').fetch('name')
          end

          def added_files(payload)
            extract_files(payload, 'added')
          end

          def modified_files(payload)
            extract_files(payload, 'modified')
          end

          def author(payload)
            payload.fetch('user_name')
          end

          def extract_files(payload, state)
            payload.fetch('commits').flat_map { |c| c[state] }.uniq
          end
        end
      end
    end
  end
end
