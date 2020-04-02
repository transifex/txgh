require 'spec_helper'
require 'helpers/sqs/sqs_test_message'
require 'json'

describe TxghQueue::Backends::Sqs::MessageAttributes do
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
    it 'extracts the history sequence from the message attributes' do
      attributes = described_class.from_message(message)
      expect(attributes.history_sequence).to be_a(TxghQueue::Backends::Sqs::HistorySequence)
      expect(attributes.history_sequence.sequence.first[:status]).to(
        eq('retry_without_delay')
      )
    end
  end

  describe '.from_h' do
    it 'creates the history sequence from the hash elements' do
      attributes = described_class.from_h(attributes_hash)
      expect(attributes.history_sequence).to be_a(TxghQueue::Backends::Sqs::HistorySequence)
      expect(attributes.history_sequence.sequence.first[:status]).to(
        eq('retry_without_delay')
      )
    end
  end

  describe '#to_h' do
    it 'converts the history sequence into a hash' do
      attributes = described_class.from_message(message).to_h
      expect(attributes).to eq(
        history_sequence: {
          data_type: 'String',
          string_value: [
            status: 'retry_without_delay'
          ].to_json
        }
      )
    end
  end

  describe '#dup' do
    it 'duplicates the attributes' do
      original_attributes = described_class.from_message(message)
      copied_attributes = original_attributes.dup
      expect(original_attributes.object_id).to_not eq(copied_attributes.object_id)
      expect(original_attributes.history_sequence.object_id).to_not(
        eq(copied_attributes.object_id)
      )
    end
  end
end
