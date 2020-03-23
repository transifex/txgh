require 'spec_helper'
require 'helpers/gitlab_payload_builder'

include TxghServer
include TxghServer::Webhooks::Gitlab

describe DeleteAttributes do
  let(:repo_name) { 'my_repo' }
  let(:ref) { 'heads/my_ref' }

  let(:payload) do
    GitlabPayloadBuilder.delete_payload(repo_name, ref)
  end

  describe '#from_webhook_payload' do
    let(:attributes) { DeleteAttributes.from_webhook_payload(payload.to_h) }

    it 'pulls out repo name' do
      expect(attributes.repo_name).to eq(repo_name)
    end

    it 'pulls out ref' do
      expect(attributes.ref).to eq("refs/#{ref}")
    end

    it 'pulls out ref type' do
      expect(attributes.ref_type).to eq('branch')
    end
  end
end
