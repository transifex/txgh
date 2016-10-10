require 'spec_helper'

include TxghQueue::Backends

describe Sqs::Config, auto_configure: true do
  let(:queue_config) { sqs_queue_config }

  describe '.queues' do
    it 'lists all queues' do
      queues = described_class.queues
      queues.each { |q| expect(q).to be_a(Sqs::Queue) }
      expect(queues.map(&:name).sort).to eq(%w(test-queue test-queue-2))
    end
  end

  describe '.failure_queue' do
    it 'returns the failure queue' do
      expect(described_class.failure_queue).to be_a(Sqs::Queue)
      expect(described_class.failure_queue.name).to eq('test-failure-queue')
    end
  end

  describe '.get_queue' do
    it 'pulls out a single queue object' do
      queue = described_class.get_queue('test-queue')
      expect(queue).to be_a(Sqs::Queue)
      expect(queue.name).to eq('test-queue')
    end
  end
end
