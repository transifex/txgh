# encoding: UTF-8

require 'pry-nav'
require 'rake'
require 'rspec'
require 'txgh'
require 'vcr'
require 'webmock'
require 'yaml'

require 'helpers/nil_logger'

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
      'tx_config' => "config/#{project_name}.config"
    }
  end

  let(:repo_config) do
    {
      'api_username' => 'github_api_username',
      'api_token' => 'github_api_token',
      'push_source_to' => project_name,
      'branch' => branch,
      'name' => repo_name
    }
  end

  let(:tx_config) do
    Txgh::TxConfig.load(
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
    )
  end

  let(:yaml_config) do
    {
      'txgh' => {
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
    }
  end

  let(:transifex_project) do
    TransifexProject.new(project_config, tx_config, transifex_api)
  end

  let(:github_repo) do
    GithubRepo.new(repo_config, github_api)
  end
end

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding(integration: true) unless ENV['FULL_SPEC']
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/integration/cassettes'
  config.hook_into :webmock

  txgh_config = Dir.chdir('./spec/integration') do
    Txgh::KeyManager.config_from_project('test-project-88')
  end

  config.filter_sensitive_data('<GITHUB_TOKEN>') do
    txgh_config.repo_config['api_token']
  end

  config.filter_sensitive_data('<TRANSIFEX_PASSWORD>') do
    txgh_config.project_config['api_password']
  end
end
