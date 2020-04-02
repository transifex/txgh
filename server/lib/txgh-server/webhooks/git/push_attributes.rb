module TxghServer
  module Webhooks
    module Git
      class PushAttributes
        ATTRIBUTES = [
          :event, :repo_name, :ref, :before, :after,
          :added_files, :modified_files, :author
        ]

        class << self
          def from_webhook_payload(payload)
            new(
              ATTRIBUTES.each_with_object({}) do |attr, ret|
                ret[attr] = public_send(attr, payload)
              end
            )
          end

          def event(payload)
            'push'
          end

          def ref(payload)
            payload.fetch('ref')
          end

          def before(payload)
            payload.fetch('before')
          end

          def after(payload)
            payload.fetch('after')
          end

          def modified_files(payload)
            extract_files(payload, 'modified')
          end
        end

        def files
          @files ||= added_files + modified_files
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
