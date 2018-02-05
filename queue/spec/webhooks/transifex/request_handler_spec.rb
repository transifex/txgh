require 'spec_helper'
require 'helpers/nil_logger'
require 'helpers/standard_txgh_setup'
require 'helpers/test_request'
require 'helpers/test_backend'

include TxghQueue::Webhooks

describe Transifex::RequestHandler, auto_configure: true do
  include StandardTxghSetup

  let(:logger) { NilLogger.new }
  let(:body) { payload.to_json }
  let(:request) { TestRequest.new(body: body) }
  let(:handler) { described_class.new(request, logger) }
  let(:payload) do
    { 'project' => project_name, 'resource' => resource_slug, 'language' => 'pt' }
  end

  describe '#handle_request' do
    let(:queue_config) { {} }

    it "responds with an error when a queue backend isn't configured" do
      allow(handler).to receive(:authentic_request?).and_return(true)
      response = handler.handle_request

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
      let(:producer) { backend.producer_for('transifex.hook') }

      it 'does not enqueue if unauthorized' do
        expect { handler.handle_request }.to_not(
          change { producer.enqueued_jobs.size }
        )
      end

      it 'responds with an unauthorized status' do
        response = handler.handle_request
        expect(response.status).to eq(401)
      end

      context 'with an authentic request' do
        before(:each) do
          allow(handler).to receive(:authentic_request?).and_return(true)
        end

        it 'enqueues the job' do
          expect { handler.handle_request }.to(
            change { producer.enqueued_jobs.size }.from(0).to(1)
          )
        end

        it 'enqueues with the correct parameters' do
          handler.handle_request
          params = producer.enqueued_jobs.first
          expect(params[:payload]).to include(
            txgh_event: 'transifex.hook',
            project: project_name,
            resource: resource_slug,
            language: 'pt'
          )
        end

        it 'responds with an ok status code' do
          response = handler.handle_request
          expect(response.status).to eq(202)
        end
      end
    end
  end
end
