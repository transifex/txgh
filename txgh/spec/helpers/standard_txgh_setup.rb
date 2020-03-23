require 'helpers/nil_logger'
require 'yaml'

module StandardTxghSetup
  extend RSpec::SharedContext

  let(:logger) { NilLogger.new }
  let(:github_api) { double(:github_api) }
  let(:transifex_api) { double(:transifex_api) }

  let(:project_name) { 'my_awesome_project' }
  let(:resource_slug) { 'my_resource' }
  let(:github_repo_name) { 'my_org/my_repo' }
  let(:gitlab_repo_name) { 'my_org/gitlab_repo' }
  let(:branch) { 'master' }
  let(:tag) { 'all' }
  let(:ref) { 'heads/master' }
  let(:language) { 'ko_KR' }
  let(:supported_languages) { [language] }
  let(:translations) { 'translation file contents' }
  let(:diff_point) { nil }
  let(:organization) { 'myorg' }
  let(:commit_message_template) { nil }  # i.e. use the default

  let(:project_config) do
    {
      'api_username' => 'transifex_api_username',
      'api_password' => 'transifex_api_password',
      'push_translations_to' => github_repo_name,
      'name' => project_name,
      'tx_config' => "raw://#{tx_config_raw}",
      'webhook_secret' => 'abc123',
      'auto_delete_resources' => 'true',
      'languages' => supported_languages,
      'organization' => organization
    }
  end

  let(:github_config) do
    {
      'api_username' => 'github_api_username',
      'api_token' => 'github_api_token',
      'git_repo_source' => 'github',
      'push_source_to' => project_name,
      'branch' => branch,
      'tag' => tag,
      'name' => github_repo_name,
      'webhook_secret' => 'abc123',
      'diff_point' => diff_point,
      'commit_message' => commit_message_template
    }
  end

  let(:gitlab_config) do
    {
      'api_token' => 'gitlab_api_token',
      'git_repo_source' => 'gitlab',
      'push_source_to' => project_name,
      'branch' => branch,
      'name' => gitlab_repo_name,
      'webhook_secret' => 'abc123',
      'diff_point' => diff_point,
      'commit_message' => commit_message_template
    }
  end

  let(:tx_config_raw) do
    """
    [main]
    host = https://www.transifex.com
    lang_map = pt-BR:pt, ko-KR:ko

    [#{project_name}.#{resource_slug}]
    file_filter = translations/<lang>/sample.yml
    source_file = sample.yml
    source_lang = en
    type = YML
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
          github_repo_name => github_config
        }
      },
      'gitlab' => {
        'repos' => {
          gitlab_repo_name => github_config
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
    Txgh::TransifexProject.new(project_config, transifex_api)
  end

  let(:git_repo) do
    Txgh::GithubRepo.new(github_config, github_api)
  end
end
