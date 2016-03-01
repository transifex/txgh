require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe KeyManager do
  include StandardTxghSetup

  describe '.config_from_project' do
    it 'creates a config object' do
      config = KeyManager.config_from_project(project_name)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_project(project_name)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(repo_config)
    end
  end

  describe '.config_from_repo' do
    it 'creates a config object' do
      config = KeyManager.config_from_repo(repo_name)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_repo(repo_name)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(repo_config)
    end
  end

  describe '.config_from' do
    it 'creates a config object' do
      config = KeyManager.config_from(project_name, repo_name)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from(project_name, repo_name)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(repo_config)
    end
  end

  describe '.tx_config' do
    let(:config) { KeyManager.config_from(project_name, repo_name) }
    let(:project) { config.transifex_project }
    let(:repo) { config.github_repo }

    it 'loads tx config from the given file' do
      path = 'file://path/to/tx_config'
      project_config.merge!('tx_config' => path)
      expect(TxConfig).to receive(:load_file).with('path/to/tx_config').and_return(:tx_config)
      config = KeyManager.tx_config(project, repo)
      expect(config).to eq(:tx_config)
    end

    context 'with git-based config' do
      before(:each) do
        project_config.merge!('tx_config' => 'git://./tx.config')
      end

      it 'raises an error if asked to load config from a git repository and no ref is given' do
        expect { KeyManager.tx_config(project, repo) }.to raise_error(TxghError)
      end

      it "raises an error if the git repo doesn't contain the requested config file" do
        expect(repo.api).to receive(:download).and_raise(Octokit::NotFound)
        expect { KeyManager.tx_config(project, repo, 'my_branch') }.to(
          raise_error(ConfigNotFoundError)
        )
      end

      it 'loads tx config from a git repository' do
        expect(repo.api).to(
          receive(:download)
            .with(repo.name, './tx.config', 'my_branch')
            .and_return("[main]\nlang_map = ko:ko_KR")
        )

        config = KeyManager.tx_config(project, repo, 'my_branch')
        expect(config.lang_map).to eq({ 'ko' => 'ko_KR' })
      end
    end

    it 'loads raw tx config' do
      project_config.merge!('tx_config' => "raw://[main]\nlang_map = ko:ko_KR")
      config = KeyManager.tx_config(project, repo)
      expect(config.lang_map).to eq({ 'ko' => 'ko_KR' })
    end
  end
end
