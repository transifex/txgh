require 'spec_helper'

describe TxghQueue::Config, auto_configure: true do
  describe '.backend' do
    it 'identifies the class to use for the queue backend' do
      expect(described_class.backend).to eq(TxghQueue::TestBackend)
    end
  end

  describe '.options' do
    it 'identifies the backend options' do
      expect(described_class.options).to eq(queue_config[:options])
    end
  end
end
