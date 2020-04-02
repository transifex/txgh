require 'spec_helper'

describe TxghQueue::ErrorHandlers::StandardErrors do
  describe '.can_handle?' do
    it 'can reply to StandardError' do
      expect(described_class.can_handle?(StandardError.new)).to eq(true)
    end

    it 'can reply to things that inherit from StandardError' do
      expect(described_class.can_handle?(RuntimeError.new)).to eq(true)
    end
  end

  describe '.status_for' do
    it 'always responds with fail' do
      expect(described_class.status_for(StandardError.new)).to eq(TxghQueue::Status.fail)
      expect(described_class.status_for('foo')).to eq(TxghQueue::Status.fail)
    end
  end
end
