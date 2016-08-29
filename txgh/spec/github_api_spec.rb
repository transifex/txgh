require 'spec_helper'
require 'base64'

include Txgh

describe GithubApi do
  let(:client) { double(:client) }
  let(:api) { GithubApi.create_from_client(client, repo) }
  let(:repo) { 'my_org/my_repo' }
  let(:branch) { 'master' }
  let(:sha) { 'abc123' }

  describe '#tree' do
    it 'retrieves a git tree using the client' do
      expect(client).to receive(:tree).with(repo, sha, recursive: 1)
      api.tree(sha)
    end
  end

  describe '#blob' do
    it 'retrieves a git blob using the client' do
      expect(client).to receive(:blob).with(repo, sha)
      api.blob(sha)
    end
  end

  describe '#create_ref' do
    it 'creates the given ref using the client' do
      expect(client).to receive(:create_ref).with(repo, branch, sha)
      api.create_ref(branch, sha)
    end

    it 'returns false on client error' do
      expect(client).to receive(:create_ref).and_raise(StandardError)
      expect(api.create_ref(branch, sha)).to eq(false)
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

      api.update_contents(branch, { path => new_contents }, 'message')
    end

    it "doesn't update the file contents if the file hasn't changed" do
      expect(client).to(
        receive(:contents)
          .with(repo, { ref: branch, path: path })
          .and_return({ sha: old_sha, content: Base64.encode64(old_contents) })
      )

      expect(client).to_not receive(:update_contents)

      api.update_contents(branch, { path => old_contents }, 'message')
    end

    it "creates the file if it doesn't already exist" do
      new_contents = 'foobar'

      # file doesn't exist, raise octokit error
      expect(client).to receive(:contents).and_raise(Octokit::NotFound)

      expect(client).to(
        receive(:update_contents)
          .with(repo, path, 'message', '0' * 40, new_contents, { branch: branch })
      )

      api.update_contents(branch, { path => new_contents }, 'message')
    end
  end

  describe '#get_commit' do
    it 'retrieves the given commit using the client' do
      expect(client).to receive(:commit).with(repo, sha)
      api.get_commit(sha)
    end
  end

  describe '#get_ref' do
    it 'retrieves the given ref (i.e. branch) using the client' do
      expect(client).to receive(:ref).with(repo, sha)
      api.get_ref(sha)
    end
  end

  describe '#download' do
    let(:path) { 'path/to/file.xyz' }

    it 'downloads the file from the given branch' do
      expect(client).to(
        receive(:contents)
          .with(repo, path: path, ref: branch)
          .and_return(
            content: 'content', encoding: 'utf-8'
          )
      )

      expect(api.download(path, branch)).to eq({ content: 'content' })
    end

    it 'encodes the string using the encoding specified in the response' do
      content = 'ありがと'.encode('UTF-16')

      expect(client).to(
        receive(:contents)
          .with(repo, path: path, ref: branch)
          .and_return(
            content: content, encoding: 'utf-16'
          )
      )

      result = api.download(path, branch)
      expect(result[:content].encoding).to eq(Encoding::UTF_16)
      expect(result[:content]).to eq(content)
    end

    it 'automatically decodes base64-encoded content' do
      expect(client).to(
        receive(:contents)
          .with(repo, path: path, ref: branch)
          .and_return(
            content: Base64.encode64('content'), encoding: 'base64'
          )
      )

      expect(api.download(path, branch)).to eq({ content: 'content' })
    end
  end
end
