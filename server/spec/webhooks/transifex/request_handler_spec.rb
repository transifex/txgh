require 'spec_helper'
require 'helpers/nil_logger'
require 'helpers/standard_txgh_setup'
require 'helpers/test_request'
require 'helpers/test_backend'

include TxghServer::Webhooks

describe Transifex::RequestHandler do
  include StandardTxghSetup

  let(:logger) { NilLogger.new }
  let(:body) { URI.encode_www_form(payload.to_a) }
  let(:request) { TestRequest.new(body: body) }
  let(:handler) { described_class.new(request, logger) }
  let(:payload) { { 'project' => project_name, 'resource' => resource_slug, 'language' => 'pt' } }

  describe '#handle_request' do
    it 'does not execute if unauthorized' do
      expect_any_instance_of(Transifex::HookHandler).to_not receive(:execute)
      response = handler.handle_request
      expect(response.status).to eq(401)
    end

    context 'with an authentic request' do
      before(:each) do
        allow(handler).to receive(:authentic_request?).and_return(true)
      end

      it 'handles the request with the hook handler' do
        expect_any_instance_of(Transifex::HookHandler).to receive(:execute).and_return(:response)
        expect(handler.handle_request).to eq(:response)
      end
    end
  end

  describe '#enqueue' do
    it "responds with an error when a queue backend isn't configured" do
      allow(handler).to receive(:authentic_request?).and_return(true)
      response = handler.enqueue

      expect(response.body.first[:error]).to(
        eq('Internal server error: No queue backend has been configured')
      )

      expect(response.status).to eq(500)
    end

    context 'with a queue configured' do
      let(:queue_config) do
        {
          backend: 'test',
          options: {
            queues: %w(test-queue)
          }
        }
      end

      let(:backend) { TxghQueue::Config.backend }
      let(:producer) { backend.producer_for("transifex.hook") }

      before(:each) do
        allow(TxghQueue::Config).to(
          receive(:raw_config).and_return(queue_config)
        )
      end

      after(:each) { backend.reset! }

      it 'does not enqueue if unauthorized' do
        expect { handler.enqueue }.to_not change { producer.enqueued_jobs.size }
      end

      it 'responds with an unauthorized status' do
        response = handler.enqueue
        expect(response.status).to eq(401)
      end

      context 'with an authentic request' do
        before(:each) do
          allow(handler).to receive(:authentic_request?).and_return(true)
        end

        it 'enqueues the job' do
          expect { handler.enqueue }.to(
            change { producer.enqueued_jobs.size }.from(0).to(1)
          )
        end

        it 'enqueues with the correct parameters' do
          handler.enqueue
          params = producer.enqueued_jobs.first
          expect(params[:payload]).to include(
            txgh_event: 'transifex.hook',
            project: project_name,
            resource: resource_slug,
            language: 'pt'
          )
        end

        it 'responds with an ok status code' do
          response = handler.enqueue
          expect(response.status).to eq(202)
        end
      end
    end
  end
end
