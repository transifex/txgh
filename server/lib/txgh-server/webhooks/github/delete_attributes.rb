module TxghServer
  module Webhooks
    module Github
      class DeleteAttributes
        ATTRIBUTES = [
          :repo_name, :ref, :ref_type
        ]

        class << self
          def from_webhook_payload(payload)
            new(
              ATTRIBUTES.each_with_object({}) do |attr, ret|
                ret[attr] = public_send(attr, payload)
              end
            )
          end

          def repo_name(payload)
            payload.fetch('repository').fetch('full_name')
          end

          def ref(payload)
            payload.fetch('ref')
          end

          def ref_type(payload)
            payload.fetch('ref_type')
          end
        end

        attr_reader *ATTRIBUTES

        def initialize(options = {})
          ATTRIBUTES.each do |attr|
            instance_variable_set(
              "@#{attr}", options.fetch(attr) { options.fetch(attr.to_s) }
            )
          end
        end

        def to_h
          ATTRIBUTES.each_with_object({}) do |attr, ret|
            ret[attr] = public_send(attr)
          end
        end

      end
    end
  end
end
