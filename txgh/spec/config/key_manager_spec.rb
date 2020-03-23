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
      expect(config.repo_config).to eq(github_config)
    end

    it "raises an error if config can't be found" do
      expect { KeyManager.config_from_project('justkidding') }.to(
        raise_error(Txgh::ProjectConfigNotFoundError)
      )
    end

    it "raises an error if the scheme can't be recognized" do
      # remove the scheme
      allow(Txgh::Config::KeyManager).to(
        receive(:raw_config).and_return(YAML.dump(base_config))
      )

      expect { KeyManager.config_from_project(project_name) }.to(
        raise_error(Txgh::InvalidProviderError)
      )
    end
  end

  describe '.config_from_repo' do
    it 'creates a config object' do
      config = KeyManager.config_from_repo(github_repo_name)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_repo(github_repo_name)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(github_config)
    end

    it "raises an error if config can't be found" do
      expect { KeyManager.config_from_repo('hahayeahright') }.to(
        raise_error(Txgh::RepoConfigNotFoundError)
      )
    end

    it "raises an error if the scheme can't be recognized" do
      # remove the scheme
      allow(Txgh::Config::KeyManager).to(
        receive(:raw_config).and_return(YAML.dump(base_config))
      )

      expect { KeyManager.config_from_repo(github_repo_name) }.to(
        raise_error(InvalidProviderError)
      )
    end
  end

  describe '.config_from' do
    it 'creates a config object' do
      config = KeyManager.config_from(project_name, github_repo_name)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from(project_name, github_repo_name)
      expect(config.project_config).to eq(project_config)
      expect(config.repo_config).to eq(github_config)
    end
  end

  describe '#project_names' do
    it "gets an array of all the configured project's names" do
      expect(KeyManager.project_names).to eq([project_name])
    end
  end
end
