require 'spec_helper'

include Txgh

describe GithubRepo do
  let(:repo_name) { 'my_org/my_repo' }
  let(:branch) { 'master' }
  let(:config) { { 'name' => repo_name, 'branch' => branch } }
  let(:api) { :api }
  let(:repo) { GithubRepo.new(config, api) }

  describe '#name' do
    it 'retrieves the repo name from the config' do
      expect(repo.name).to eq(repo_name)
    end
  end

  describe '#branch' do
    it 'retrieves the branch name from the config' do
      expect(repo.branch).to eq(branch)
    end
  end
end
