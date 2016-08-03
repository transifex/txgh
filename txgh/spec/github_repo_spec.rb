require 'spec_helper'

include Txgh

describe GithubRepo do
  let(:repo_name) { 'my_org/my_repo' }
  let(:branch) { 'master' }
  let(:tag) { 'tags/foo' }
  let(:api) { :api }
  let(:repo) { GithubRepo.new(config, api) }
  let(:diff_point) { nil }
  let(:config) do
    {
      'name' => repo_name, 'branch' => branch, 'tag' => tag,
      'diff_point' => diff_point
    }
  end

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

  describe '#tag' do
    it 'retrieves the tag name from the config' do
      expect(repo.tag).to eq(tag)
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

  describe '#process_all_tags?' do
    it 'returns false if only one tag should be processed' do
      expect(repo.process_all_tags?).to eq(false)
    end

    context 'with all tags indicated' do
      let(:tag) { 'all' }

      it 'returns true if all tags should be processed' do
        expect(repo.process_all_tags?).to eq(true)
      end
    end
  end

  describe '#should_process_ref?' do
    context 'with all branches indicated' do
      let(:branch) { 'all' }

      it 'returns true if all branches should be processed' do
        expect(repo.should_process_ref?('heads/foo')).to eq(true)
      end
    end

    context 'with all tags indicated' do
      let(:tag) { 'all' }

      it 'returns true if all tags should be processed' do
        expect(repo.should_process_ref?('tags/foo')).to eq(true)
      end
    end

    it 'returns true if the given branch matches the configured one' do
      expect(repo.should_process_ref?('heads/master')).to eq(true)
    end

    it "returns false if the given branch doesn't match the configured one" do
      expect(repo.should_process_ref?('heads/foo')).to eq(false)
    end

    it 'returns true if the branch contains the special L10N text' do
      expect(repo.should_process_ref?('heads/L10N_foo')).to eq(true)
    end

    it 'returns true if the given tag matches the configured one' do
      expect(repo.should_process_ref?('tags/foo')).to eq(true)
    end

    it "returns false if the given tag doesn't match the configured one" do
      expect(repo.should_process_ref?('heads/foobar')).to eq(false)
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

  describe '#github_config_tag' do
    context 'with all tags indicated' do
      let(:tag) { 'all' }

      it "doesn't modify the passed tag, i.e. returns 'all'" do
        expect(repo.github_config_tag).to eq('all')
      end
    end

    context 'with a nil tag' do
      let(:tag) { nil }

      it 'returns nil' do
        expect(repo.github_config_tag).to be_nil
      end
    end

    context 'with a configured tag' do
      let(:tag) { 'tags/foobar' }

      it 'leaves the prefix intact' do
        expect(repo.github_config_tag).to eq('tags/foobar')
      end
    end
  end

  describe '#upload_diffs?' do
    it 'returns false by default' do
      expect(repo.upload_diffs?).to eq(false)
    end

    context 'with a configured diff point' do
      let(:diff_point) { 'heads/master' }

      it 'returns true when a diff point is configured' do
        expect(repo.upload_diffs?).to eq(true)
      end
    end
  end

  describe '#diff_point' do
    context 'with a configured diff point' do
      let(:diff_point) { 'heads/master' }

      it 'returns the provided diff point' do
        expect(repo.diff_point).to eq(diff_point)
      end
    end
  end
end
