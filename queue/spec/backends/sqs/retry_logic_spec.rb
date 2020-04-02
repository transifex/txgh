require 'spec_helper'
require 'helpers/sqs/sqs_test_message'

describe TxghQueue::Backends::Sqs::RetryLogic do
  context 'with overall retries exceeded' do
    let(:logic) { described_class.new(message_attributes, current_status) }
    let(:current_status) { TxghQueue::Status.retry_without_delay }
    let(:message) { SqsTestMessage.new('abc123', '{}', message_attributes.to_h) }
    let(:message_attributes) do
      TxghQueue::Backends::Sqs::MessageAttributes.from_h(
        history_sequence: {
          string_value: described_class::OVERALL_MAX_RETRIES.times.map do
            { status: 'retry_without_delay' }
          end.to_json
        }
      )
    end

    describe '#retries_exceeded?' do
      it 'indicates retries have been exceeded' do
        expect(logic.retries_exceeded?).to eq(true)
      end
    end

    describe '#retry?' do
      it 'indicates another retry should not be attempted' do
        expect(logic.retry?).to eq(false)
      end
    end

    describe '#next_delay_seconds' do
      it 'raises an error' do
        expect { logic.next_delay_seconds }.to raise_error(TxghQueue::Backends::Sqs::RetriesExceededError)
      end
    end

    describe '#sqs_retry_params' do
      it 'raises an error' do
        expect { logic.sqs_retry_params }.to raise_error(TxghQueue::Backends::Sqs::RetriesExceededError)
      end
    end
  end

  context 'with a run of no-delay retries' do
    let(:logic) { described_class.new(message_attributes, current_status) }
    let(:current_status) { TxghQueue::Status.retry_without_delay }
    let(:message) { SqsTestMessage.new('abc123', '{}', message_attributes.to_h) }
    let(:message_attributes) do
      TxghQueue::Backends::Sqs::MessageAttributes.from_h(
        history_sequence: {
          string_value: [
            { status: 'retry_without_delay' },
            { status: 'retry_without_delay' },
            { status: 'retry_without_delay' }
          ].to_json
        }
      )
    end

    describe '#retries_exceeded?' do
      it 'indicates retries have not been exceeded' do
        expect(logic.retries_exceeded?).to eq(false)
      end
    end

    describe '#retry?' do
      it 'indicates another retry may be attempted' do
        expect(logic.retry?).to eq(true)
      end
    end

    describe '#next_delay_seconds' do
      it 'indicates a delay of zero seconds' do
        expect(logic.next_delay_seconds).to eq(0)
      end
    end

    describe '#sqs_retry_params' do
      it 'contains the correct parameters' do
        expect(logic.sqs_retry_params[:message_attributes]).to(
          eq(message_attributes.to_h)
        )
      end
    end

    context 'and a delayed current status' do
      let(:current_status) { TxghQueue::Status.retry_with_delay }

      describe '#next_delay_seconds' do
        it 'indicates a first-stage delay' do
          expect(logic.next_delay_seconds).to(
            eq(described_class::DELAY_INTERVALS.first)
          )
        end
      end
    end
  end

  context 'with a run of delayed retries' do
    let(:logic) { described_class.new(message_attributes, current_status) }
    let(:current_status) { TxghQueue::Status.retry_with_delay }
    let(:message) { SqsTestMessage.new('abc123', '{}', message_attributes.to_h) }
    let(:message_attributes) do
      TxghQueue::Backends::Sqs::MessageAttributes.from_h(
        history_sequence: {
          string_value: [
            { status: 'retry_with_delay' },
            { status: 'retry_with_delay' },
            { status: 'retry_with_delay' }
          ].to_json
        }
      )
    end

    describe '#retries_exceeded?' do
      it 'indicates retries have not been exceeded' do
        expect(logic.retries_exceeded?).to eq(false)
      end
    end

    describe '#retry?' do
      it 'indicates another retry may be attempted' do
        expect(logic.retry?).to eq(true)
      end
    end

    describe '#next_delay_seconds' do
      it 'indicates a third-stage delay' do
        expect(logic.next_delay_seconds).to eq(
          described_class::DELAY_INTERVALS[2]
        )
      end
    end

    describe '#sqs_retry_params' do
      it 'contains the correct parameters, including the delay' do
        expect(logic.sqs_retry_params).to eq(
          message_attributes: message_attributes.to_h,
          delay_seconds: described_class::DELAY_INTERVALS[2]
        )
      end
    end

    context 'and a non-delayed current status' do
      let(:current_status) { TxghQueue::Status.retry_without_delay }

      describe '#next_delay_seconds' do
        it 'indicates no delay' do
          expect(logic.next_delay_seconds).to eq(0)
        end
      end
    end
  end
end
