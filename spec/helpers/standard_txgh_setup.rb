require 'helpers/nil_logger'
require 'yaml'

module StandardTxghSetup
  extend RSpec::SharedContext

  let(:logger) { NilLogger.new }
  let(:github_api) { double(:github_api) }
  let(:transifex_api) { double(:transifex_api) }

  let(:project_name) { 'my_awesome_project' }
  let(:resource_slug) { 'my_resource' }
  let(:repo_name) { 'my_org/my_repo' }
  let(:branch) { 'master' }
  let(:ref) { 'heads/master' }
  let(:language) { 'ko_KR' }
  let(:translations) { 'translation file contents' }

  let(:project_config) do
    {
      'api_username' => 'transifex_api_username',
      'api_password' => 'transifex_api_password',
      'push_translations_to' => repo_name,
      'name' => project_name,
      'tx_config' => "raw://#{tx_config_raw}",
      'webhook_secret' => 'abc123',
      'auto_delete_resources' => 'true'
    }
  end

  let(:repo_config) do
    {
      'api_username' => 'github_api_username',
      'api_token' => 'github_api_token',
      'push_source_to' => project_name,
      'branch' => branch,
      'name' => repo_name,
      'webhook_secret' => 'abc123'
    }
  end

  let(:tx_config_raw) do
    """
    [main]
    host = https://www.transifex.com
    lang_map = pt-BR:pt, ko-KR:ko

    [#{project_name}.#{resource_slug}]
    file_filter = translations/<lang>/sample.po
    source_file = sample.po
    source_lang = en
    type = PO
    """
  end

  let(:tx_config) do
    Txgh::Config::TxConfig.load(tx_config_raw)
  end

  before(:each) do
    allow(Txgh::Config::KeyManager).to(
      receive(:raw_config) { "raw://#{YAML.dump(base_config)}" }
    )
  end

  let(:base_config) do
    {
      'github' => {
        'repos' => {
          repo_name => repo_config
        }
      },
      'transifex' => {
        'projects' => {
          project_name => project_config
        }
      }
    }
  end

  let(:transifex_project) do
    TransifexProject.new(project_config, transifex_api)
  end

  let(:github_repo) do
    GithubRepo.new(repo_config, github_api)
  end
end
