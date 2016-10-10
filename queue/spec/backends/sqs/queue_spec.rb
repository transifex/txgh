require 'spec_helper'

include TxghQueue::Backends

describe Sqs::Queue do
  let(:options) { { name: 'test-queue', region: 'us-east-1', events: %w(a b c) } }
  let(:queue) { described_class.new(options) }

  describe '#client' do
    it 'instantiates an AWS SQS client' do
      expect(queue.client).to be_a(Aws::SQS::Client)
    end
  end

  describe '#url' do
    it 'grabs the queue URL from the SQS client' do
      queue_url = double(:QueueUrl, queue_url: 'test-queue')

      expect(queue.client).to(
        receive(:get_queue_url)
          .with(queue_name: 'test-queue')
          .and_return(queue_url)
      )

      queue.url
    end
  end

  describe '#receive_message' do
    it 'proxies to the client' do
      url = 'test://host'
      allow(queue).to receive(:url).and_return(url)
      expect(queue.client).to receive(:receive_message).with(queue_url: url, foo: 'bar')
      queue.receive_message(foo: 'bar')
    end
  end

  describe '#send_message' do
    it 'proxies to the client' do
      url = 'test://host'
      body = 'All your base are belong to us'
      allow(queue).to receive(:url).and_return(url)

      expect(queue.client).to(
        receive(:send_message).with(message_body: body, queue_url: url, foo: 'bar')
      )

      queue.send_message(body, foo: 'bar')
    end
  end

  describe '#delete_message' do
    it 'proxies to the client' do
      url = 'test://host'
      receipt_handle = 'abc123'
      allow(queue).to receive(:url).and_return(url)

      expect(queue.client).to(
        receive(:delete_message).with(queue_url: url, receipt_handle: receipt_handle)
      )

      queue.delete_message(receipt_handle)
    end
  end
end
