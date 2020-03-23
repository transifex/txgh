require 'spec_helper'
require 'helpers/github_payload_builder'
require 'helpers/standard_txgh_setup'

include TxghServer
include TxghServer::Webhooks::Github

describe DeleteHandler do
  include StandardTxghSetup

  let(:handler) do
    DeleteHandler.new(transifex_project, git_repo, logger, attributes)
  end

  let(:attributes) do
    DeleteAttributes.from_webhook_payload(payload.to_h)
  end

  let(:payload) do
    GithubPayloadBuilder.delete_payload(github_repo_name, ref)
  end

  it 'deletes resources' do
    expect_any_instance_of(Txgh::ResourceDeleter).to receive(:delete_resources)
    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end

  it 'does not delete resources if auto resource deletions are disabled' do
    project_config['auto_delete_resources'] = 'false'
    expect(transifex_api).to_not receive(:delete)
    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end
end
