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

  describe '#should_process_branch?' do
    context 'with all branches indicated' do
      let(:branch) { 'all' }

      it 'returns true if all branches should be processed' do
        expect(repo.should_process_branch?('heads/foo')).to eq(true)
      end
    end

    it 'returns true if the given branch matches the configured one' do
      expect(repo.should_process_branch?('heads/master')).to eq(true)
    end

    it "returns false if the given branch doesn't match the configured one" do
      expect(repo.should_process_branch?('heads/foo')).to eq(false)
    end

    it 'returns true if the branch contains the special L10N text' do
      expect(repo.should_process_branch?('heads/L10N_foo')).to eq(true)
    end
  end

  describe '#github_config_branch' do
    context 'with all branches indicated' do
      let(:branch) { 'all' }

      it "doesn't modify the passed branch, i.e. returns 'all'" do
        expect(repo.github_config_branch).to eq('all')
      end
    end

    context 'with a nil branch' do
      let(:branch) { nil }

      it 'chooses master by default' do
        expect(repo.github_config_branch).to eq('heads/master')
      end
    end

    context 'with a configured branch' do
      let(:branch) { 'foobar' }

      it 'correctly prefixes the branch' do
        expect(repo.github_config_branch).to eq('heads/foobar')
      end
    end
  end
end
