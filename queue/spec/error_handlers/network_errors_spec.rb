require 'spec_helper'

describe TxghQueue::ErrorHandlers::NetworkErrors do
  describe '.can_handle?' do
    it 'can reply to faraday connection errors' do
      error = Faraday::ConnectionFailed.new(StandardError.new)
      expect(described_class.can_handle?(error)).to eq(true)
    end

    it 'can reply to faraday timeout errors' do
      error = Faraday::TimeoutError.new
      expect(described_class.can_handle?(error)).to eq(true)
    end

    it 'can reply to ruby open timeout errors' do
      error = Net::OpenTimeout.new
      expect(described_class.can_handle?(error)).to eq(true)
    end

    it 'can reply to ruby read timeout errors' do
      error = Net::ReadTimeout.new
      expect(described_class.can_handle?(error)).to eq(true)
    end
  end

  describe '.status_for' do
    it 'retries with delay on faraday connection error' do
      error = Faraday::ConnectionFailed.new(StandardError.new)
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.retry_with_delay)
    end

    it 'retries with delay on faraday timeout error' do
      error = Faraday::TimeoutError.new
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.retry_with_delay)
    end

    it 'retries with delay on ruby open timeout error' do
      error = Net::OpenTimeout.new
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.retry_with_delay)
    end

    it 'retries with delay on ruby read timeout error' do
      error = Net::ReadTimeout.new
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.retry_with_delay)
    end
  end
end
