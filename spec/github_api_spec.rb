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

  describe '#update_contents' do
    let(:path) { 'path/to/file.txt' }
    let(:old_contents) { 'abc123' }
    let(:old_sha) { Utils.git_hash_blob(old_contents) }

    it 'updates the given file contents' do
      new_contents = 'def456'

      expect(client).to(
        receive(:contents)
          .with(repo, { ref: branch, path: path })
          .and_return({ sha: old_sha, content: Base64.encode64(old_contents) })
      )

      expect(client).to(
        receive(:update_contents)
          .with(repo, path, 'message', old_sha, new_contents, { branch: branch })
      )

      api.update_contents(repo, branch, { path => new_contents }, 'message')
    end

    it "doesn't update the file contents if the file hasn't changed" do
      expect(client).to(
        receive(:contents)
          .with(repo, { ref: branch, path: path })
          .and_return({ sha: old_sha, content: Base64.encode64(old_contents) })
      )

      expect(client).to_not receive(:update_contents)

      api.update_contents(repo, branch, { path => old_contents }, 'message')
    end
  end

  describe '#commit' do
    let(:path) { 'path/to/translations' }
    let(:other_path) { 'other/path/to/translations' }

    before(:each) do
      allow(client).to receive(:create_blob).with(repo, :new_content).and_return(:blob_sha)
      allow(client).to receive(:ref).with(repo, branch).and_return(object: { sha: :branch_sha })
      allow(client).to receive(:commit).with(repo, :branch_sha).and_return(commit: { tree: { sha: :base_tree_sha } })
      allow(client).to receive(:create_tree).and_return(sha: :new_tree_sha)
    end

    it 'creates a new commit and updates the branch' do
      expect(client).to(
        receive(:create_commit)
          .with(repo, 'message', :new_tree_sha, :branch_sha)
          .and_return(sha: :new_commit_sha)
      )

      expect(client).to receive(:update_ref).with(repo, branch, :new_commit_sha, false)
      api.commit(repo, branch, { path => :new_content }, 'message', true)
    end

    it 'updates multiple files at a time' do
      allow(client).to receive(:create_blob).with(repo, :other_content).and_return(:blob_sha_2)

      expect(client).to(
        receive(:create_commit)
          .with(repo, 'message', :new_tree_sha, :branch_sha)
          .and_return(sha: :new_commit_sha)
      )

      expect(client).to receive(:update_ref).with(repo, branch, :new_commit_sha, false)
      content_map = { path => :new_content, other_path => :other_content }
      api.commit(repo, branch, content_map, 'message', true)
    end

    context 'with an empty commit' do
      before(:each) do
        allow(client).to(
          receive(:compare)
            .with(repo, :branch_sha, :new_commit_sha)
            .and_return(files: [])
        )

        expect(client).to(
          receive(:create_commit)
            .with(repo, 'message', :new_tree_sha, :branch_sha)
            .and_return(sha: :new_commit_sha)
        )
      end

      it 'does not allow empty commits by default' do
        expect(client).to_not receive(:update_ref)
        api.commit(repo, branch, { path => :new_content }, 'message')
      end
    end

    context 'with a non-empty commit' do
      before(:each) do
        allow(client).to(
          receive(:compare)
            .with(repo, :branch_sha, :new_commit_sha)
            .and_return(files: %w(abc def))
        )

        expect(client).to(
          receive(:create_commit)
            .with(repo, 'message', :new_tree_sha, :branch_sha)
            .and_return(sha: :new_commit_sha)
        )
      end

      it 'updates the ref as expected' do
        expect(client).to receive(:update_ref).with(repo, branch, :new_commit_sha, false)
        api.commit(repo, branch, { path => :new_content }, 'message')
      end
    end
  end

  describe '#get_commit' do
    it 'retrieves the given commit using the client' do
      expect(client).to receive(:commit).with(repo, sha)
      api.get_commit(repo, sha)
    end
  end

  describe '#get_ref' do
    it 'retrieves the given ref (i.e. branch) using the client' do
      expect(client).to receive(:ref).with(repo, sha)
      api.get_ref(repo, sha)
    end
  end

  describe '#download' do
    it 'downloads the file from the given branch' do
      path = 'path/to/file.xyz'

      expect(client).to receive(:ref).with(repo, branch).and_return(object: { sha: :branch_sha })
      expect(client).to receive(:commit).with(repo, :branch_sha).and_return(commit: { tree: { sha: :base_tree_sha } })
      expect(client).to receive(:tree).with(repo, :base_tree_sha, recursive: 1).and_return(
        tree: [{ path: path, sha: :blob_sha }]
      )

      expect(client).to receive(:blob).with(repo, :blob_sha).and_return(
        { 'content' => :blob, 'encoding' => 'utf-8' }
      )

      expect(api.download(repo, path, branch)).to eq(:blob)
    end
  end
end
