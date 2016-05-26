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

  # process all branches
  let(:branch) { 'all' }

  let(:payload) do
    GithubPayloadBuilder.delete_payload(repo_name, ref)
  end

  let(:resource) { tx_config.resources.first }

  let(:resource_api_response) do
    [resource.to_api_h.merge('categories' => ["branch:#{ref}"])]
  end

  let(:resource_slug_with_branch) do
    "#{resource_slug}-#{Utils.slugify(ref)}"
  end

  it 'deletes the correct resource from transifex' do
    expect(transifex_api).to(
      receive(:get_resources).and_return(resource_api_response)
    )

    expect(transifex_api).to receive(:delete_resource) do |tx_resource|
      expect(tx_resource.project_slug).to eq(project_name)
      expect(tx_resource.resource_slug).to eq(resource_slug_with_branch)
    end

    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end

  it "does not delete resources that don't have a matching branch" do
    handler.payload['ref'] = 'heads/im_fake'
    expect(transifex_api).to(
      receive(:get_resources).and_return(resource_api_response)
    )

    expect(transifex_api).to_not receive(:delete)
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
