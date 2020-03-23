require 'spec_helper'
require 'helpers/gitlab_payload_builder'
require 'helpers/nil_logger'
require 'helpers/standard_txgh_setup'
require 'helpers/test_request'

include TxghServer::Webhooks

describe Gitlab::RequestHandler do
  include StandardTxghSetup

  let(:logger) { NilLogger.new }
  let(:ref) { 'heads/my_ref' }
  let(:headers) { { 'HTTP_X_GITLAB_EVENT' => event } }
  let(:body) { payload.to_json }
  let(:request) { TestRequest.new(body: body, headers: headers) }
  let(:handler) { described_class.new(request, logger) }

  describe '#handle_request' do
    context 'push event' do
      let(:event) { 'Push Hook' }
      let(:payload) { GitlabPayloadBuilder.push_payload(gitlab_repo_name, ref).tap { |p| p.add_commit } }

      it 'does not execute if unauthorized' do
        expect_any_instance_of(Gitlab::PushHandler).to_not receive(:execute)
        response = handler.handle_request
        expect(response.status).to eq(401)
      end

      context 'with an authentic request' do
        before(:each) do
          allow(handler).to receive(:authentic_request?).and_return(true)
        end

        it 'handles the request with the push handler' do
          expect_any_instance_of(Gitlab::PushHandler).to receive(:execute).and_return(:response)
          expect(handler.handle_request).to eq(:response)
        end
      end
    end

    context 'delete event' do
      let(:event) { 'Push Hook' }
      let(:payload) { GitlabPayloadBuilder.delete_payload(gitlab_repo_name, ref) }

      it 'does not execute if unauthorized' do
        expect_any_instance_of(Gitlab::DeleteHandler).to_not receive(:execute)
        response = handler.handle_request
        expect(response.status).to eq(401)
      end

      context 'with an authentic request' do
        before(:each) do
          allow(handler).to receive(:authentic_request?).and_return(true)
        end

        it 'handles the request with the delete handler' do
          expect_any_instance_of(Gitlab::DeleteHandler).to receive(:execute).and_return(:response)
          expect(handler.handle_request).to eq(:response)
        end
      end
    end

    context 'unrecognized event' do
      let(:event) { 'foo' }
      let(:payload) { { repository: { full_name: gitlab_repo_name } } }

      it 'responds with a 400' do
        allow(handler).to receive(:authentic_request?).and_return(true)
        response = handler.handle_request
        expect(response.status).to eq(400)
      end
    end
  end
end
