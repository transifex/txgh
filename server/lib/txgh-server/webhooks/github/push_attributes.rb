module TxghServer
  module Webhooks
    module Github
      class PushAttributes < TxghServer::Webhooks::Git::PushAttributes
        class << self
          def repo_name(payload)
            payload.fetch('repository').fetch('full_name')
          end

          def added_files(payload)
            extract_files(payload, 'added')
          end

          def modified_files(payload)
            extract_files(payload, 'modified')
          end

          def author(payload)
            if head_commit = payload.fetch('head_commit')
              head_commit.fetch('committer').fetch('name')
            else
              # fall back to pusher if no head commit
              payload.fetch('pusher').fetch('name')
            end
          end

          def extract_files(payload, state)
            payload.fetch('commits').flat_map { |c| c[state] }.uniq
          end
        end
      end
    end
  end
end
