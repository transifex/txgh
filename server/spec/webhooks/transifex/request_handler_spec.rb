require 'spec_helper'
require 'helpers/nil_logger'
require 'helpers/standard_txgh_setup'
require 'helpers/test_request'

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
end
