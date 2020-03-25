require 'spec_helper'
require 'helpers/sqs/sqs_test_message'

describe TxghQueue::Backends::Sqs::Job, auto_configure: true do
  let(:queue_config) { sqs_queue_config }
  let(:queue) { TxghQueue::Backends::Sqs::Config.queues.first }
  let(:failure_queue) { TxghQueue::Backends::Sqs::Config.failure_queue }
  let(:logger) { NilLogger.new }
  let(:body) { { 'foo' => 'bar' } }
  let(:message) { SqsTestMessage.new('123abc', body.to_json) }
  let(:new_message) { SqsTestMessage.new('456def', body.to_json) }
  let(:job) { described_class.new(message, queue, logger) }

  shared_examples "it updates the message's history sequence" do |status, queue_sym|
    it 'updates the history sequence with failure details for an exception' do
      error = StandardError.new('foobar')
      error.set_backtrace('path/to/file.rb:10')
      result = TxghQueue::Result.new(status, error)
      expect(job).to receive(:process).with(body).and_return(result)

      # this call to send_message signifies a retry
      expect(send(queue_sym)).to receive(:send_message) do |body, attributes|
        message_attributes = TxghQueue::Backends::Sqs::MessageAttributes.from_h(attributes[:message_attributes])
        current_retry = message_attributes.history_sequence.current
        expect(current_retry).to include(
          response_type: 'error',
          class: 'StandardError',
          message: 'foobar',
          backtrace: 'path/to/file.rb:10'
        )

        new_message
      end

      job.complete
    end

    it 'updates the history sequence with failure details for a txgh response' do
      response = TxghServer::Response.new(502, 'Bad gateway')
      result = TxghQueue::Result.new(status, response)
      expect(job).to receive(:process).with(body).and_return(result)

      # this call to send_message signifies a retry
      expect(send(queue_sym)).to receive(:send_message) do |body, attributes|
        message_attributes = TxghQueue::Backends::Sqs::MessageAttributes.from_h(attributes[:message_attributes])
        current_retry = message_attributes.history_sequence.current
        expect(current_retry).to include(
          response_type: 'response',
          code: 502,
          body: 'Bad gateway'
        )

        new_message
      end

      job.complete
    end
  end

  describe '#complete' do
    it 'processes a single job and deletes the message' do
      result = TxghQueue::Result.new(TxghQueue::Status.ok, TxghServer::Response.new(200, 'Ok'))
      expect(queue).to receive(:delete_message).with(message.receipt_handle)
      expect(job).to receive(:process).with(body).and_return(result)
      job.complete
    end

    context 'error reporting' do
      let(:error) { StandardError.new('jelly beans') }
      let(:result) { TxghQueue::Result.new(TxghQueue::Status.fail, error) }

      before(:each) do
        expect(job).to receive(:process).and_return(result)
        expect(queue).to receive(:delete_message).with(message.receipt_handle)
      end

      it 'reports errors to the event system' do
        expect(failure_queue).to receive(:send_message)

        expect(Txgh.events).to receive(:publish_error) do |e, params|
          expect(e).to eq(error)
          expect(params).to eq(
            payload: body, message_id: message.message_id, queue: queue.name
          )
        end

        job.complete
      end

      it 'includes error tracking details returned from publishing the event' do
        expect(Txgh.events).to receive(:publish_error).and_return(foo: 'bar')
        expect(failure_queue).to receive(:send_message) do |body, attributes|
          message_attributes = TxghQueue::Backends::Sqs::MessageAttributes.from_h(attributes[:message_attributes])
          current_retry = message_attributes.history_sequence.current
          expect(current_retry).to include(error_tracking: { foo: 'bar' })
        end

        job.complete
      end
    end

    context 'retries' do
      let(:response) { TxghServer::Response.new(502, 'Bad gateway') }

      before(:each) do
        # should delete the old message
        expect(queue).to receive(:delete_message).with(message.receipt_handle)
      end

      it 're-enqueues the message if told to retry' do
        response = TxghServer::Response.new(502, 'Bad gateway')
        result = TxghQueue::Result.new(TxghQueue::Status.retry_without_delay, response)
        expect(job).to receive(:process).with(body).and_return(result)

        # this call to send_message signifies a retry
        expect(queue).to receive(:send_message) do |body, attributes|
          message_attributes = TxghQueue::Backends::Sqs::MessageAttributes.from_h(attributes[:message_attributes])
          history_sequence = message_attributes.history_sequence.sequence.map { |elem| elem[:status] }
          expect(history_sequence).to eq(%w(retry_without_delay))
          new_message
        end

        job.complete
      end

      it 're-enqueues with delay if told to do so' do
        response = TxghServer::Response.new(502, 'Bad gateway')
        result = TxghQueue::Result.new(TxghQueue::Status.retry_with_delay, response)
        expect(job).to receive(:process).with(body).and_return(result)

        # this call to send_message signifies a retry
        expect(queue).to receive(:send_message) do |body, attributes|
          message_attributes = TxghQueue::Backends::Sqs::MessageAttributes.from_h(attributes[:message_attributes])
          history_sequence = message_attributes.history_sequence.sequence.map { |elem| elem[:status] }
          expect(history_sequence).to eq(%w(retry_with_delay))

          expect(attributes[:delay_seconds]).to eq(
            TxghQueue::Backends::Sqs::RetryLogic::DELAY_INTERVALS.first
          )

          new_message
        end

        job.complete
      end

      context 'with all retries exceeded' do
        let(:message) do
          SqsTestMessage.new('123abc', body.to_json, {
            'history_sequence' => {
              'string_value' => (TxghQueue::Backends::Sqs::RetryLogic::OVERALL_MAX_RETRIES - 1).times.map do
                { status: 'retry_without_delay' }
              end.to_json
            }
          })
        end

        it 'deletes the message and adds it to the failure queue' do
          response = TxghServer::Response.new(502, 'Bad gateway')
          result = TxghQueue::Result.new(TxghQueue::Status.retry_with_delay, response)
          expect(job).to receive(:process).with(body).and_return(result)
          expect(failure_queue).to receive(:send_message).and_return(new_message)
          job.complete
        end
      end

      it_behaves_like "it updates the message's history sequence", TxghQueue::Status.retry_without_delay, :queue
      it_behaves_like "it updates the message's history sequence", TxghQueue::Status.retry_with_delay, :queue
    end

    context 'failures' do
      before(:each) do
        expect(queue).to receive(:delete_message).with(message.receipt_handle)
      end

      it 'sends the message to the failure queue' do
        result = TxghQueue::Result.new(TxghQueue::Status.fail, TxghServer::Response.new(500, '💩'))
        expect(failure_queue).to receive(:send_message).with(body.to_json, anything)
        expect(job).to receive(:process).with(body).and_return(result)
        job.complete
      end

      it_behaves_like "it updates the message's history sequence", TxghQueue::Status.fail, :failure_queue
    end
  end
end
