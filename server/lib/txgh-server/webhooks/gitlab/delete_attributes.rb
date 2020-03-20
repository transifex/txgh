module TxghServer
  module Webhooks
    module Gitlab
      class DeleteAttributes < TxghServer::Webhooks::Github::DeleteAttributes
        ATTRIBUTES = [
          :event, :repo_name, :ref, :ref_type
        ]

        class << self
          def from_webhook_payload(payload)
            new(
              ATTRIBUTES.each_with_object({}) do |attr, ret|
                ret[attr] = public_send(attr, payload)
              end
            )
          end

          def event(_payload)
            'delete'
          end

          def repo_name(payload)
            payload.fetch('repository').fetch('name')
          end

          def ref(payload)
            payload.fetch('ref')
          end

          def ref_type(_payload)
            'branch'
          end
        end

        attr_reader *ATTRIBUTES
      end
    end
  end
end
