require 'spec_helper'

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
    data = '{"project": "test-project-88","resource": "samplepo","language": "el_GR","translated": 100}'
    post '/transifex', JSON.parse(data)
    expect(last_response).to be_ok
  end

  it 'verifies the github hook endpoint works' do
    data = { 'payload' => github_postbody }
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    expect(last_response).to be_ok
  end

  it 'verifies the github release hook endpoint works' do
    data = { 'payload' => github_postbody_release }
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    expect(last_response).to be_ok
  end

  it 'verifies the github l10n hook endpoint works' do
    data = { 'payload' => github_postbody_l10n }
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    expect(last_response).to be_ok
  end
end
