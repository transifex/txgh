require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe ResourceDeleter do
  include StandardTxghSetup

  # process all branches
  let(:branch) { 'heads/master' }

  let(:deleter) do
    ResourceDeleter.new(transifex_project, github_repo, branch)
  end

  let(:resource_api_response) do
    [resource.to_api_h.merge('categories' => ["branch:#{branch}"])]
  end

  let(:resource) { tx_config.resources.first }

  let(:resource_slug_with_branch) do
    "#{resource_slug}-#{Txgh::Utils.slugify(ref)}"
  end

  it 'deletes the correct resource from transifex' do
    expect(transifex_api).to(
      receive(:get_resources).and_return(resource_api_response)
    )

    expect(transifex_api).to receive(:delete_resource) do |tx_resource|
      expect(tx_resource.project_slug).to eq(project_name)
      expect(tx_resource.resource_slug).to eq(resource_slug_with_branch)
    end

    deleter.delete_resources
  end

  it 'handles the case when no categories are present' do
    expect(transifex_api).to(
      receive(:get_resources).and_return([resource.to_api_h.merge('categories' => nil)])
    )

    expect { deleter.delete_resources }.to_not raise_error
  end

  it "does not delete resources that don't have a matching branch" do
    deleter = ResourceDeleter.new(transifex_project, github_repo, 'heads/fake')
    expect(transifex_api).to(
      receive(:get_resources).and_return(resource_api_response)
    )

    expect(transifex_api).to_not receive(:delete)
    deleter.delete_resources
  end
end
