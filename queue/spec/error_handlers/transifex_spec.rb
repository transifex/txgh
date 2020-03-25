require 'spec_helper'

describe TxghQueue::ErrorHandlers::Transifex do
  describe '.can_handle?' do
    it 'can reply to transifex api errors' do
      error = Txgh::TransifexApiError.new(500, 'Internal error')
      expect(described_class.can_handle?(error)).to eq(true)
    end

    it 'can reply to transifex not found errors' do
      error = Txgh::TransifexNotFoundError.new
      expect(described_class.can_handle?(error)).to eq(true)
    end

    it 'can reply to transifex unauthorized errors' do
      error = Txgh::TransifexUnauthorizedError.new
      expect(described_class.can_handle?(error)).to eq(true)
    end

    it "can't reply to unsupported error classes" do
      expect(described_class.can_handle?(StandardError.new)).to eq(false)
    end
  end

  describe '.status_for' do
    it 'retries with delay on api error' do
      error = Txgh::TransifexApiError.new(500, 'Internal error')
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.retry_with_delay)
    end

    it 'fails on not found error' do
      error = Txgh::TransifexNotFoundError.new
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.fail)
    end

    it 'fails on unauthorized error' do
      error = Txgh::TransifexUnauthorizedError.new
      expect(described_class.status_for(error)).to eq(TxghQueue::Status.fail)
    end
  end
end
