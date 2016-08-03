require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh::Config

describe ConfigPair do
  include StandardTxghSetup

  let(:config) do
    ConfigPair.new(project_config, repo_config)
  end

  describe '#github_repo' do
    it 'instantiates a github repo with the right config' do
      repo = config.github_repo
      expect(repo).to be_a(GithubRepo)
      expect(repo.name).to eq(repo_name)
      expect(repo.branch).to eq(branch)
    end
  end

  describe '#transifex_project' do
    it 'instantiates a transifex project with the right config' do
      project = config.transifex_project
      expect(project).to be_a(TransifexProject)
      expect(project.name).to eq(project_name)
      expect(tx_config.resources.first.resource_slug).to eq(resource_slug)
    end
  end

  describe '#transifex_api' do
    it 'instantiates an API instance' do
      api = config.transifex_api
      expect(api).to be_a(TransifexApi)
      expect(api.connection.headers).to include('Authorization')
    end
  end

  describe '#github_api' do
    it 'instantiates an API instance' do
      api = config.github_api
      expect(api).to be_a(GithubApi)
      expect(api.client.login).to eq(repo_config['api_username'])
      expect(api.client.access_token).to eq(repo_config['api_token'])
    end
  end
end
