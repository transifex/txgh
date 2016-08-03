require 'spec_helper'
require 'helpers/github_payload_builder'
require 'helpers/standard_txgh_setup'

include TxghServer
include TxghServer::Webhooks::Github

describe PushHandler do
  include StandardTxghSetup

  let(:handler) do
    PushHandler.new(
      project: transifex_project,
      repo: github_repo,
      payload: payload.to_h,
      logger: logger
    )
  end

  let(:payload) do
    GithubPayloadBuilder.push_payload(repo_name, ref)
  end

  let(:modified_files) do
    file_sha = 'def456'
    tx_config.resources.map do |resource|
      { 'path' => resource.source_file, 'sha' => file_sha.next! }
    end
  end

  let(:updater) { double(:updater) }

  before(:each) do
    payload.add_commit(
      modified: modified_files.map { |f| f['path'] }
    )

    allow(Txgh::ResourceUpdater).to receive(:new).and_return(updater)
  end

  it 'correctly uploads modified resources to transifex' do
    tx_config.resources.each do |resource|
      expect(updater).to(
        receive(:update_resource) do |resource, sha, categories|
          expect(resource.project_slug).to eq(project_name)
          expect(resource.resource_slug).to eq(resource_slug)
          expect(sha).to eq(payload.head_commit[:id])
          expect(categories).to eq('author' => 'Test User')
        end
      )

      expect(github_api).to(
        receive(:get_ref).with(repo_name, ref).and_return(
          object: { sha: payload.head_commit[:id] }
        )
      )
    end

    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq(true)
  end

  context 'with an L10N branch' do
    let(:ref) { 'tags/L10N_my_branch' }

    it 'creates an L10N tag' do
      expect(updater).to receive(:update_resource)

      # this is what we actually care about in this test
      expect(github_api).to(
        receive(:create_ref).with(
          repo_name, 'heads/L10N', payload.head_commit[:id]
        )
      )

      expect(github_api).to(
        receive(:get_ref).with(repo_name, ref).and_return(
          object: { sha: payload.head_commit[:id] }
        )
      )

      response = handler.execute
      expect(response.status).to eq(200)
      expect(response.body).to eq(true)
    end
  end

  context 'with a deleted branch' do
    let(:before) { nil }
    let(:after) { '0' * 40 }

    let(:payload) do
      GithubPayloadBuilder.push_payload(repo_name, ref, before, after)
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
