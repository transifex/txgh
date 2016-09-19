require 'spec_helper'
require 'helpers/github_payload_builder'

include TxghServer
include TxghServer::Webhooks::Github

describe PushAttributes do
  let(:repo_name) { 'my_repo' }
  let(:ref) { 'heads/my_ref' }
  let(:added) { ['added_file.txt'] }
  let(:modified) { ['modified_file.txt'] }

  let(:payload) do
    GithubPayloadBuilder.push_payload(repo_name, ref).tap do |payload|
      payload.add_commit(added: added, modified: modified)
    end
  end

  describe '#from_webhook_payload' do
    let(:attributes) { PushAttributes.from_webhook_payload(payload.to_h) }

    it 'pulls out repo name' do
      expect(attributes.repo_name).to eq(repo_name)
    end

    it 'pulls out ref' do
      expect(attributes.ref).to eq("refs/#{ref}")
    end

    it 'pulls out before sha' do
      expect(attributes.before).to eq(payload.to_h['before'])
    end

    it 'pulls out after sha' do
      expect(attributes.after).to eq(payload.to_h['after'])
    end

    it 'pulls out added files' do
      expect(attributes.added_files.to_a).to eq(added)
    end

    it 'pulls out modified files' do
      expect(attributes.modified_files.to_a).to eq(modified)
    end

    it 'combines all files into one handy array' do
      expect(attributes.files.sort).to eq((added + modified).sort)
    end

    it 'pulls out the author' do
      expect(attributes.author).to eq('Test User')
    end
  end
end
