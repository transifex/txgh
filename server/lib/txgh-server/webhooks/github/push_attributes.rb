require 'set'

module TxghServer
  module Webhooks
    module Github
      class PushAttributes
        ATTRIBUTES = [
          :repo_name, :ref, :before, :after,
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

          def repo_name(payload)
            payload.fetch('repository').fetch('full_name')
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

          def added_files(payload)
            extract_files(payload, 'added')
          end

          def modified_files(payload)
            extract_files(payload, 'modified')
          end

          def author(payload)
            payload.fetch('head_commit').fetch('committer').fetch('name')
          end

          def extract_files(payload, state)
            payload.fetch('commits').flat_map { |c| c[state] }.uniq
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
