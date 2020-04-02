require 'spec_helper'

require 'base64'
require 'json'
require 'pathname'
require 'rack/test'
require 'helpers/integration_setup'
require 'uri'
require 'yaml'
require_relative '../../lib/txgh-server/application'

describe 'hook integration tests', integration: true do
  include Rack::Test::Methods
  include IntegrationSetup

  def app
    @app ||= TxghServer::WebhookEndpoints.new
  end

  around(:each) do |example|
    Dir.chdir('./spec/integration') do
      example.run
    end
  end

  before(:all) do
    VCR.configure do |config|
      config.filter_sensitive_data('<GITHUB_TOKEN>') do
        base_config[git_source]['repos']['txgh-bot/txgh-test-resources']['api_token']
      end

      config.filter_sensitive_data('<TRANSIFEX_PASSWORD>') do
        base_config['transifex']['projects'][project_name]['api_password']
      end
    end
  end

  before(:each) do
    header('Content-Type', 'application/json')

    allow(Txgh::Config::KeyManager).to(
      receive(:raw_config).and_return("raw://#{YAML.dump(base_config)}")
    )
  end

  let(:payload_path) do
    Pathname(File.dirname(__FILE__)).join('payloads')
  end

  let(:github_postbody) do
    File.read(payload_path.join('github_postbody.json'))
  end

  let(:gitlab_postbody) do
    File.read(payload_path.join('gitlab_postbody.json'))
  end

  let(:github_postbody_release) do
    File.read(payload_path.join('github_postbody_release.json'))
  end

  let(:config) do
    Txgh::Config::KeyManager.config_from(project_name, repo_name)
  end

  def sign_github_request(body)
    header(
      TxghServer::GithubRequestAuth::GITHUB_HEADER,
      TxghServer::GithubRequestAuth.compute_signature(
        body, config.git_repo.webhook_secret
      )
    )
  end

  def sign_transifex_request(body)
    date_str = Time.now.strftime('%a, %d %b %Y %H:%M:%S GMT')

    header('Date', date_str)
    header('X-Tx-Url', 'http://example.org/transifex')

    header(
      TxghServer::TransifexRequestAuth::TRANSIFEX_HEADER,
      TxghServer::TransifexRequestAuth.compute_signature(
        http_verb: 'POST',
        url: 'http://example.org/transifex',
        date_str: date_str,
        content: body,
        secret: config.transifex_project.webhook_secret
      )
    )
  end

  it 'loads correct project config' do
    expect(config.project_config).to_not be_nil
  end

  context 'GitLab' do
    let(:git_source) { 'gitlab' }
    let(:repo_name) { 'idanci/txgl-test' }
    let(:project_name) { 'txgl-test' }

    it 'verifies the gitlab hook endpoint works' do
      VCR.use_cassette('gitlab_hook_endpoint') do
        header 'X-Gitlab-Token', base_config[git_source]['repos'][repo_name]['webhook_secret']
        header 'X-GitLab-Event', 'Push Hook'
        header 'content-type', 'application/x-www-form-urlencoded'
        post '/gitlab', gitlab_postbody

        expect(last_response).to be_ok
      end
    end

    it 'verifies the transifex hook endpoint works' do
      VCR.use_cassette('transifex_hook_endpoint') do
        params = {
          'project' => project_name, 'resource' => 'enyml-heads_test_hook',
          'language' => 'de', 'translated' => 100
        }

        payload = params.to_json

        sign_transifex_request(payload)
        post '/transifex', payload

        expect(last_response).to be_ok
      end
    end
  end

  context 'GitHub' do
    it 'verifies the github hook endpoint works' do
      VCR.use_cassette('github_hook_endpoint') do
        sign_github_request(github_postbody)
        header 'X-GitHub-Event', 'push'
        header 'content-type', 'application/x-www-form-urlencoded'
        post '/github', github_postbody
        expect(last_response).to be_ok
      end
    end

    it 'verifies the github release hook endpoint works' do
      VCR.use_cassette('github_release_hook_endpoint') do
        sign_github_request(github_postbody_release)
        header 'X-GitHub-Event', 'push'
        header 'content-type', 'application/x-www-form-urlencoded'
        post '/github', github_postbody_release
        expect(last_response).to be_ok
      end
    end
  end
end
