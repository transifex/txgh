require 'spec_helper'

include Txgh

describe GithubApi do
  let(:client) { double(:client) }
  let(:api) { GithubApi.create_from_client(client) }
  let(:repo) { 'my_org/my_repo' }
  let(:branch) { 'master' }
  let(:sha) { 'abc123' }

  describe '#tree' do
    it 'retrieves a git tree using the client' do
      expect(client).to receive(:tree).with(repo, sha, recursive: 1)
      api.tree(repo, sha)
    end
  end

  describe '#blob' do
    it 'retrieves a git blob using the client' do
      expect(client).to receive(:blob).with(repo, sha)
      api.blob(repo, sha)
    end
  end

  describe '#create_ref' do
    it 'creates the given ref using the client' do
      expect(client).to receive(:create_ref).with(repo, branch, sha)
      api.create_ref(repo, branch, sha)
    end

    it 'returns false on client error' do
      expect(client).to receive(:create_ref).and_raise(StandardError)
      expect(api.create_ref(repo, branch, sha)).to eq(false)
    end
  end

  describe '#commit' do
    it 'creates a new blob, tree, and commit, then updates the branch' do
      path = 'path/to/translations'

      expect(client).to receive(:create_blob).with(repo, :new_content).and_return(:blob_sha)
      expect(client).to receive(:ref).with(repo, branch).and_return(object: { sha: :branch_sha })
      expect(client).to receive(:commit).with(repo, :branch_sha).and_return(commit: { tree: { sha: :base_tree_sha } })
      expect(client).to receive(:create_tree).and_return(sha: :new_tree_sha)

      expect(client).to(
        receive(:create_commit)
          .with(repo, "Updating translations for #{path}", :new_tree_sha, :branch_sha)
          .and_return(sha: :new_commit_sha)
      )

      expect(client).to receive(:update_ref).with(repo, branch, :new_commit_sha)

      api.commit(repo, branch, path, :new_content)
    end
  end

  describe '#get_commit' do
    it 'retrieves the given commit using the client' do
      expect(client).to receive(:commit).with(repo, sha)
      api.get_commit(repo, sha)
    end
  end

  describe '#download' do
    it 'downloads the file from the given branch' do
      path = 'path/to/file.xyz'

      expect(client).to receive(:ref).with(repo, branch).and_return(object: { sha: :branch_sha })
      expect(client).to receive(:commit).with(repo, :branch_sha).and_return(commit: { tree: { sha: :base_tree_sha } })
      expect(client).to receive(:tree).with(repo, :base_tree_sha).and_return(
        tree: [{ path: path, sha: :blob_sha }]
      )

      expect(client).to receive(:blob).with(repo, :blob_sha).and_return(
        { 'content' => :blob, 'encoding' => 'utf-8' }
      )

      expect(api.download(repo, path, branch)).to eq(:blob)
    end
  end
end
