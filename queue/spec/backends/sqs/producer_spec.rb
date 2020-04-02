require 'spec_helper'
require 'securerandom'

describe TxghQueue::Backends::Sqs::Producer, auto_configure: true do
  let(:queue_config) { sqs_queue_config }
  let(:logger) { NilLogger.new }
  let(:queues) { TxghQueue::Backends::Sqs::Config.queues }
  let(:producer) { described_class.new(queues, logger) }

  describe '#enqueue' do
    it 'sends a message to each SQS queue' do
      payload = { abc: 'def' }
      message_ids = []

      queues.each do |queue|
        message_ids << SecureRandom.hex
        message = double(:Message, message_id: message_ids.last)

        expect(queue).to(
          receive(:send_message)
            .with(payload.to_json, foo: 'bar')
            .and_return(message)
        )
      end

      result = producer.enqueue(payload, foo: 'bar')
      expect(result).to eq(message_ids: message_ids)
    end
  end
end
