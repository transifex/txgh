require 'aws-sdk'

module TxghQueue
  module Backends
    module Sqs
      class Queue
        attr_reader :name, :region, :events

        def initialize(options = {})
          @name = options.fetch(:name)
          @region = options.fetch(:region)
          @events = options.fetch(:events, [])
        end

        def client
          @client ||= Aws::SQS::Client.new(region: region)
        end

        def url
          @url ||= client.get_queue_url(queue_name: name).queue_url
        end

        def receive_message(options = {})
          client.receive_message(options.merge(queue_url: url))
        end

        def send_message(body, options = {})
          params = options.merge(message_body: body, queue_url: url)
          client.send_message(params)
        end

        def delete_message(receipt_handle)
          params = { queue_url: url, receipt_handle: receipt_handle }
          client.delete_message(params)
        end

        private

        def sqs_attributes
          @sqs_attributes ||= client.get_queue_attributes(queue_url: url)
        end
      end
    end
  end
end
