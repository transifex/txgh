require 'spec_helper'

require 'rack/test'
require 'helpers/integration_setup'
require_relative '../../lib/txgh-server/application'

describe 'trigger integration tests', integration: true do
  include Rack::Test::Methods
  include IntegrationSetup

  let(:git_source) { 'gitlab' }
  let(:repo_name) { 'idanci/txgl-test' }
  let(:project_name) { 'txgl-test' }

  def app
    @app ||= TxghServer::TriggerEndpoints.new
  end

  around(:each) do |example|
    Dir.chdir('./spec/integration') do
      example.run
    end
  end

  it 'verifies the pull endpoint works' do
    VCR.use_cassette('pull') do
      params = {
        project_slug: project_name,
        resource_slug: 'enyml-heads_master',
        branch: 'master'
      }

      patch '/pull', params

      expect(last_response).to be_ok
    end
  end

  it 'verifies the push endpoint works' do
    VCR.use_cassette('push') do
      params = {
        project_slug: project_name,
        resource_slug: 'enyml-heads_master',
        branch: 'master'
      }

      patch '/push', params

      expect(last_response).to be_ok
    end
  end
end
