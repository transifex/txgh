require 'spec_helper'
require 'helpers/github_payload_builder'
require 'helpers/standard_txgh_setup'

include Txgh
include Txgh::Handlers::Github

describe DeleteHandler do
  include StandardTxghSetup

  let(:handler) do
    DeleteHandler.new(
      project: transifex_project,
      repo: github_repo,
      payload: payload.to_h,
      logger: logger
    )
  end

  let(:payload) do
    GithubPayloadBuilder.delete_payload(repo_name, ref)
  end

  let(:resource_slug_with_branch) do
    "#{resource_slug}-#{Utils.slugify(ref)}"
  end

  it 'deletes the correct resource from transifex' do
    expect(transifex_api).to receive(:resource_exists?).and_return(true)
    expect(transifex_api).to receive(:delete) do |tx_resource|
      expect(tx_resource.project_slug).to eq(project_name)
      expect(tx_resource.resource_slug).to eq(resource_slug_with_branch)
    end

    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end

  it 'does not delete non-existent resources' do
    expect(transifex_api).to receive(:resource_exists?).and_return(false)
    expect(transifex_api).to_not receive(:delete)
    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end

  it "responds with an error if the config can't be found" do
    allow(handler).to receive(:tx_config).and_return(nil)
    response = handler.execute
    expect(response.status).to eq(404)
    expect(response.body).to eq([
      { error: "Could not find configuration for branch '#{ref}'" }
    ])
  end
end
