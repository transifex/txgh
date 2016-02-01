require 'spec_helper'

include Txgh

describe KeyManager do
  include StandardTxghSetup

  describe '.config_from_project' do
    it 'creates a config object' do
      config = KeyManager.config_from_project(project_name, tx_config)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_project(project_name, tx_config)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(repo_config)
      expect(config.tx_config).to be_a(TxConfig)
      expect(config.tx_config.resources.first.project_slug).to eq(project_name)
    end

    it 'loads tx config from the given file if not explicitly passed in' do
      path = 'path/to/tx_config'
      project_config.merge!('tx_config' => path)
      expect(TxConfig).to receive(:load_file).with(path).and_return(:tx_config)
      config = KeyManager.config_from_project(project_name)
      expect(config.tx_config).to eq(:tx_config)
    end
  end

  describe '.config_from_repo' do
    it 'creates a config object' do
      config = KeyManager.config_from_repo(repo_name, tx_config)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_repo(repo_name, tx_config)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(repo_config)
      expect(config.tx_config).to be_a(TxConfig)
      expect(config.tx_config.resources.first.project_slug).to eq(project_name)
    end

    it 'loads tx config from the given file if not explicitly passed in' do
      path = 'path/to/tx_config'
      project_config.merge!('tx_config' => path)
      expect(TxConfig).to receive(:load_file).with(path).and_return(:tx_config)
      config = KeyManager.config_from_repo(repo_name)
      expect(config.tx_config).to eq(:tx_config)
    end
  end

  describe '.config_from' do
    it 'creates a config object' do
      config = KeyManager.config_from(project_name, repo_name, tx_config)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from(project_name, repo_name, tx_config)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(repo_config)
      expect(config.tx_config).to be_a(TxConfig)
      expect(config.tx_config.resources.first.project_slug).to eq(project_name)
    end

    it 'loads tx config from the given file if not explicitly passed in' do
      path = 'path/to/tx_config'
      project_config.merge!('tx_config' => path)
      expect(TxConfig).to receive(:load_file).with(path).and_return(:tx_config)
      config = KeyManager.config_from(project_name, repo_name)
      expect(config.tx_config).to eq(:tx_config)
    end
  end
end
