require 'spec_helper'

include Txgh

describe KeyManager do
  include StandardTxghSetup

  before(:each) do
    allow(KeyManager).to receive(:yaml) { yaml_config }
  end

  describe '.config_from_project' do
    it 'creates a config object from first project' do
      config = KeyManager.config_from_project(project_name, tx_config_multi_project)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object from second project' do
      config = KeyManager.config_from_project('my_second_awesome_project', tx_config_multi_project)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_project('my_second_awesome_project', tx_config_multi_project)
      expect(config.project_config).to eq(second_project_config)
      expect(config.repo_config).to eq(second_repo_config)
      expect(config.tx_config).to be_a(TxConfig)
      expect(config.tx_config.resources.first.project_slug).to eq('my_second_awesome_project')
    end
  end


  describe '.config_from_repo' do
    it 'creates a config object' do
      config = KeyManager.config_from_repo('my_org/my_second_repo', tx_config_multi_project)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from_repo('my_org/my_second_repo', tx_config_multi_project)
      expect(config.project_config).to eq(second_project_config)
      expect(config.repo_config).to eq(second_repo_config)
      expect(config.tx_config).to be_a(TxConfig)
      expect(config.tx_config.resources.first.project_slug).to eq('my_second_awesome_project')
    end
  end


  describe '.config_from' do
    it 'creates a config object' do
      config = KeyManager.config_from('my_second_awesome_project', 'my_org/my_second_repo', tx_config_multi_project)
      expect(config).to be_a(Txgh::Config)
    end

    it 'creates a config object that contains both project and repo configs' do
      config = KeyManager.config_from('my_second_awesome_project', 'my_org/my_second_repo', tx_config_multi_project)
      expect(config.project_config).to eq(second_project_config)
      expect(config.repo_config).to eq(second_repo_config)
      expect(config.tx_config).to be_a(TxConfig)
      expect(config.tx_config.resources.first.project_slug).to eq('my_second_awesome_project')
    end
  end
end
