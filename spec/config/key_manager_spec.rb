require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh
include Txgh::Config

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
end
