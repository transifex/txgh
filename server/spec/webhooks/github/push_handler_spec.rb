require 'spec_helper'
require 'helpers/github_payload_builder'
require 'helpers/standard_txgh_setup'

include TxghServer
include TxghServer::Webhooks::Github

describe PushHandler do
  include StandardTxghSetup

  let(:handler) do
    PushHandler.new(transifex_project, github_repo, logger, attributes)
  end

  let(:attributes) do
    PushAttributes.from_webhook_payload(payload.to_h)
  end

  let(:payload) do
    GithubPayloadBuilder.push_payload(github_repo_name, ref)
  end

  let(:modified_files) do
    file_sha = 'def456'
    tx_config.resources.map do |resource|
      { path: resource.source_file, sha: file_sha.next! }
    end
  end

  let(:updater) { double(:updater) }

  before(:each) do
    payload.add_commit(
      modified: modified_files.map { |f| f[:path] }
    )

    allow(Txgh::ResourceUpdater).to receive(:new).and_return(updater)
  end

  it 'correctly uploads modified resources to transifex' do
    tx_config.resources.each do |resource|
      expect(updater).to(
        receive(:update_resource) do |resource, categories|
          expect(resource.project_slug).to eq(project_name)
          expect(resource.resource_slug).to eq(resource_slug)
          expect(categories).to eq('author' => 'Test User')
        end
      )
    end

    expect(Txgh::GithubStatus).to(
      receive(:update).with(transifex_project, github_repo, ref)
    )

    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end

  context 'with an error' do
    let(:description) { 'An error done occurred, fool' }
    let(:target_url) { 'http://you-goofed.com' }

    let(:status_params) do
      { description: description, target_url: target_url }
    end

    let(:error_params) { { foo: 'bar' } }

    before(:each) do
      Txgh.events.subscribe(Txgh::Events::ERROR_CHANNEL) { error_params }
      Txgh.events.subscribe('github.status.error') { status_params }
    end

    it 'reports errors and updates the github status' do
      expect(Txgh::GithubStatus).to(
        receive(:error).with(transifex_project, github_repo, ref, status_params)
      )

      expect(handler).to receive(:should_process?).and_raise(StandardError)
      handler.execute
    end
  end

  context 'with a deleted branch' do
    let(:before) { nil }
    let(:after) { '0' * 40 }

    let(:payload) do
      GithubPayloadBuilder.push_payload(github_repo_name, ref, before, after)
    end

    it "doesn't upload anything" do
      expect(updater).to_not receive(:update_resource)
      expect(github_api).to_not receive(:create_ref)

      response = handler.execute
      expect(response.status).to eq(200)
      expect(response.body).to eq(true)
    end
  end
end
