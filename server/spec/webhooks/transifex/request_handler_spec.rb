require 'spec_helper'
require 'helpers/nil_logger'
require 'helpers/standard_txgh_setup'
require 'helpers/test_request'

include TxghServer::Webhooks

describe Transifex::RequestHandler do
  include StandardTxghSetup

  let(:logger) { NilLogger.new }
  let(:body) { payload.to_json }
  let(:signature) { 'abc123' }
  let(:headers) { { TxghServer::TransifexRequestAuth::RACK_HEADER => signature } }
  let(:request) { TestRequest.new(body: body, headers: headers, request_method: 'POST') }
  let(:handler) { described_class.new(request, logger) }
  let(:payload) { { 'project' => project_name, 'resource' => resource_slug, 'language' => 'pt' } }

  describe '#handle_request' do
    it 'publishes an event' do
      Txgh.events.subscribe('transifex.webhook_received') { false }

      expect { handler.handle_request }.to(
        change { Txgh.events.published_in('transifex.webhook_received').size }.by(1)
      )

      event = Txgh.events.published_in('transifex.webhook_received').first
      expect(event[:options][:payload]).to eq(Txgh::Utils.deep_symbolize_keys(payload))
      expect(event[:options][:raw_payload]).to eq(body)
      expect(event[:options][:signature]).to eq(signature)
      expect(event[:options][:http_verb]).to eq('POST')
    end

    it 'returns a 204 if the event handles the request' do
      Txgh.events.subscribe('transifex.webhook_received') { true }
      response = handler.handle_request
      expect(response.status).to eq(204)
    end

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
end
