require 'spec_helper'
require 'helpers/sqs/sqs_test_message'

describe TxghQueue::Backends::Sqs::Consumer, auto_configure: true do
  let(:queue_config) { sqs_queue_config }
  let(:queues) { TxghQueue::Backends::Sqs::Config.queues }
  let(:logger) { NilLogger.new }
  let(:message) { SqsTestMessage.new('abc123', '{}') }
  let(:consumer) { described_class.new(queues, logger) }

  it 'executes one job in each queue' do
    queues.each do |queue|
      job = double(:Job)
      expect(queue).to receive(:receive_message).and_return(message.to_bundle)
      expect(job).to receive(:complete)
      expect(TxghQueue::Backends::Sqs::Job).to(
        receive(:new).with(message, queue, logger).and_return(job)
      )
    end

    consumer.work
  end

  it 'reports errors' do
    errors = []
    Txgh.events.subscribe('errors') { |e| errors << e }
    expect(queues.first).to receive(:receive_message).and_raise(StandardError, 'jelly beans')
    expect { consumer.work }.to change { errors.size }.from(0).to(1)
    expect(errors.first.message).to eq('jelly beans')
  end
end
