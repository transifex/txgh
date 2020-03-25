require 'spec_helper'
require 'helpers/sqs/sqs_test_message'

describe TxghQueue::Backends::Sqs::HistorySequence do
  let(:message) { SqsTestMessage.new('abc123', '{}', attributes_hash) }
  let(:attributes_hash) do
    {
      'history_sequence' => {
        'string_value' => [{
          'status' => 'retry_without_delay'
        }].to_json
      }
    }
  end

  describe '.from_message' do
    it 'extracts the correct attributes from the given hash' do
      sequence = described_class.from_message(message)
      expect(sequence.sequence).to eq([
        { status: 'retry_without_delay' }
      ])
    end
  end

  describe '.from_h' do
    it 'extracts the correct attributes from the given hash' do
      sequence = described_class.from_h(attributes_hash)
      expect(sequence.sequence).to eq([
        { status: 'retry_without_delay' }
      ])
    end
  end

  context 'with a sequence' do
    let(:sequence) { described_class.from_message(message) }

    describe '#add' do
      it 'adds the given object to the sequence' do
        expect { sequence.add('abc') }.to(
          change { sequence.sequence.size }.by(1)
        )

        expect(sequence.sequence.last).to eq('abc')
      end
    end

    describe '#to_h' do
      it 'serializes the sequence into a hash' do
        expect(sequence.to_h).to eq(
          string_value: [{'status' => 'retry_without_delay'}].to_json,
          data_type: 'String'
        )
      end
    end

    describe '#dup' do
      it 'deep copies the sequence' do
        copied_sequence = sequence.dup
        expect(sequence.object_id).to_not eq(copied_sequence.object_id)
        expect(sequence.sequence.object_id).to_not(
          eq(copied_sequence.sequence.object_id)
        )
      end
    end

    describe '#current' do
      it 'returns the last element in the sequence' do
        expect(sequence.current).to eq(status: 'retry_without_delay')
      end
    end
  end
end
