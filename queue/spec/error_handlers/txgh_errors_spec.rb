require 'spec_helper'

describe TxghQueue::ErrorHandlers::TxghErrors do
  describe '.can_handle?' do
    it 'can reply to all configured error classes' do
      described_class::ERROR_CLASSES.keys.each do |klass|
        expect(described_class.can_handle?(klass.new)).to eq(true)
      end
    end

    it "can't reply to unsupported error classes" do
      expect(described_class.can_handle?(StandardError.new)).to eq(false)
    end
  end

  describe '.status_for' do
    it 'replies to all configured errors correctly' do
      described_class::ERROR_CLASSES.each_pair do |klass, expected_response|
        expect(described_class.status_for(klass.new)).to eq(expected_response)
      end
    end
  end
end
