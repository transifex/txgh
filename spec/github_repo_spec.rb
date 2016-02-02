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

  describe '#process_all_branches?' do
    it 'returns false if only one branch should be processed' do
      expect(repo.process_all_branches?).to eq(false)
    end

    context 'with all branches indicated' do
      let(:branch) { 'all' }

      it 'returns true if all branches should be processed' do
        expect(repo.process_all_branches?).to eq(true)
      end
    end
  end
end
