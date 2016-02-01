require 'spec_helper'

require 'base64'
require 'json'
require 'pathname'
require 'rack/test'

describe 'integration tests', integration: true do
  include Rack::Test::Methods

  def app
    @app ||= Txgh::Hooks.new
  end

  around(:each) do |example|
    Dir.chdir('./spec/integration') do
      example.run
    end
  end

  let(:base_config) do
    {
      'github' => {
        'repos' => {
          'txgh-bot/txgh-test-resources' => {
            'api_username' => 'txgh-bot',
            # github will auto-revoke a token if they notice it in one of your commits ;)
            'api_token' => Base64.decode64('YjViYWY3Nzk5NTdkMzVlMmI0OGZmYjk4YThlY2M1ZDY0NzAwNWRhZA=='),
            'push_source_to' => 'test-project-88',
            'branch' => 'master'
          }
        }
      },
      'transifex' => {
        'projects' => {
          'test-project-88' => {
            'tx_config' => './config/tx.config',
            'api_username' => 'txgh.bot',
            'api_password' => '2aqFGW99fPRKWvXBPjbrxkdiR',
            'push_translations_to' => 'txgh-bot/txgh-test-resources'
          }
        }
      }
    }
  end

  before(:all) do
    VCR.configure do |config|
      config.filter_sensitive_data('<GITHUB_TOKEN>') do
        base_config['github']['repos']['txgh-bot/txgh-test-resources']['api_token']
      end

      config.filter_sensitive_data('<TRANSIFEX_PASSWORD>') do
        base_config['transifex']['projects']['test-project-88']['api_password']
      end
    end
  end

  before(:each) do
    allow(Txgh::KeyManager).to receive(:base_config).and_return(base_config)
  end

  let(:payload_path) do
    Pathname(File.dirname(__FILE__)).join('payloads')
  end

  let(:github_postbody) do
    File.read(payload_path.join('github_postbody.json'))
  end

  let(:github_postbody_release) do
    File.read(payload_path.join('github_postbody_release.json'))
  end

  let(:github_postbody_l10n) do
    File.read(payload_path.join('github_postbody_l10n.json'))
  end

  it 'loads correct project config' do
    tx_name = 'test-project-88'
    gh_name = 'txgh-bot/txgh-test-resources'
    config = Txgh::KeyManager.config_from(tx_name, gh_name)
    expect(config.project_config).to_not be_nil
  end

  it 'verifies the transifex hook endpoint works' do
    VCR.use_cassette('transifex_hook_endpoint') do
      data = '{"project": "test-project-88","resource": "samplepo","language": "el_GR","translated": 100}'
      post '/transifex', JSON.parse(data)
      expect(last_response).to be_ok
    end
  end

  it 'verifies the github hook endpoint works' do
    VCR.use_cassette('github_hook_endpoint') do
      data = { 'payload' => github_postbody }
      header 'content-type', 'application/x-www-form-urlencoded'
      post '/github', data
      expect(last_response).to be_ok
    end
  end

  it 'verifies the github release hook endpoint works' do
    VCR.use_cassette('github_release_hook_endpoint') do
      data = { 'payload' => github_postbody_release }
      header 'content-type', 'application/x-www-form-urlencoded'
      post '/github', data
      expect(last_response).to be_ok
    end
  end

  it 'verifies the github l10n hook endpoint works' do
    VCR.use_cassette('github_l10n_hook_endpoint') do
      data = { 'payload' => github_postbody_l10n }
      header 'content-type', 'application/x-www-form-urlencoded'
      post '/github', data
      expect(last_response).to be_ok
    end
  end
end
