require 'spec_helper'

describe TxghQueue::Backends::Sqs, auto_configure: true do
  let(:queue_config) { sqs_queue_config }

  describe '.producer_for' do
    it 'looks up the queues for the given event and returns a producer object' do
      producer = described_class.producer_for('a')
      expect(producer).to be_a(TxghQueue::Backends::Sqs::Producer)
      expect(producer.queues.size).to eq(1)
      expect(producer.queues.first).to be_a(TxghQueue::Backends::Sqs::Queue)
      expect(producer.queues.first.name).to eq('test-queue')
    end

    it 'looks up multiple events if given an array' do
      producer = described_class.producer_for(%w(a d))
      expect(producer.queues.size).to eq(2)
      expect(producer.queues.map(&:name).sort).to eq(%w(test-queue test-queue-2))
    end

    it 'dedupes the list of matching queues' do
      producer = described_class.producer_for(%w(a b c d e f))
      expect(producer.queues.size).to eq(2)
      expect(producer.queues.map(&:name).sort).to eq(%w(test-queue test-queue-2))
    end
  end

  describe '.consumer_for' do
    it 'looks up the queue for the given event and returns a consumer object' do
      consumer = described_class.consumer_for('b')
      expect(consumer).to be_a(TxghQueue::Backends::Sqs::Consumer)
      expect(consumer.queues.size).to eq(1)
      expect(consumer.queues.first).to be_a(TxghQueue::Backends::Sqs::Queue)
      expect(consumer.queues.first.name).to eq('test-queue')
    end

    it 'handles the case if the event matches multiple queues' do
      consumer = described_class.consumer_for('c')
      expect(consumer.queues.size).to eq(2)
      expect(consumer.queues.map(&:name).sort).to eq(%w(test-queue test-queue-2))
    end

    it 'looks up multiple events if given an array' do
      consumer = described_class.consumer_for(%w(a d))
      expect(consumer.queues.size).to eq(2)
      expect(consumer.queues.map(&:name).sort).to eq(%w(test-queue test-queue-2))
    end

    it 'dedupes the list of matching queues' do
      consumer = described_class.consumer_for(%w(a b c d e f))
      expect(consumer.queues.size).to eq(2)
      expect(consumer.queues.map(&:name).sort).to eq(%w(test-queue test-queue-2))
    end
  end
end
