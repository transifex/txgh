require 'spec_helper'

include TxghQueue

describe Status do
  describe '.retry_without_delay' do
    it 'returns the same object' do
      expect(described_class.retry_without_delay.object_id).to eq(
        described_class.retry_without_delay.object_id
      )
    end
  end

  describe '.retry_with_delay' do
    it 'returns the same object' do
      expect(described_class.retry_with_delay.object_id).to eq(
        described_class.retry_with_delay.object_id
      )
    end
  end

  describe '.fail' do
    it 'returns the same object' do
      expect(described_class.fail.object_id).to eq(described_class.fail.object_id)
    end
  end

  describe '.ok' do
    it 'returns the same object' do
      expect(described_class.ok.object_id).to eq(described_class.ok.object_id)
    end
  end

  describe '#retry_without_delay?' do
    it 'returns true if the response matches, false otherwise' do
      expect(described_class.retry_without_delay.retry_without_delay?).to eq(true)
      expect(described_class.ok.retry_without_delay?).to eq(false)
    end
  end

  describe '#retry_with_delay?' do
    it 'returns true if the response matches, false otherwise' do
      expect(described_class.retry_with_delay.retry_with_delay?).to eq(true)
      expect(described_class.ok.retry_with_delay?).to eq(false)
    end
  end

  describe '#fail?' do
    it 'returns true if the response matches, false otherwise' do
      expect(described_class.fail.fail?).to eq(true)
      expect(described_class.ok.fail?).to eq(false)
    end
  end

  describe '#ok?' do
    it 'returns true if the response matches, false otherwise' do
      expect(described_class.ok.ok?).to eq(true)
      expect(described_class.fail.ok?).to eq(false)
    end
  end

  describe '#to_s' do
    it 'converts the status into a string' do
      expect(described_class.fail.to_s).to eq('fail')
      expect(described_class.ok.to_s).to eq('ok')
    end
  end
end
