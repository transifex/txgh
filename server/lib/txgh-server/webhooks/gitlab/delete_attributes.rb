module TxghServer
  module Webhooks
    module Gitlab
      class DeleteAttributes < TxghServer::Webhooks::Github::DeleteAttributes
        class << self
          def from_webhook_payload(payload)
            new(
              ATTRIBUTES.each_with_object({}) do |attr, ret|
                ret[attr] = public_send(attr, payload)
              end
            )
          end

          def repo_name(payload)
            payload.fetch('repository').fetch('name')
          end

          def ref(payload)
            payload.fetch('ref')
          end

          def ref_type(payload)
            raise 'CHANGEME'
            payload.fetch('ref_type')
          end
        end
      end
    end
  end
end
