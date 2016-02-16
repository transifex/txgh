require 'spec_helper'

require 'rack/test'
require 'helpers/integration_setup'

describe 'trigger integration tests', integration: true do
  include Rack::Test::Methods
  include IntegrationSetup

  def app
    @app ||= Txgh::Triggers.new
  end

  around(:each) do |example|
    Dir.chdir('./spec/integration') do
      example.run
    end
  end

  it 'verifies the pull endpoint works' do
    VCR.use_cassette('pull') do
      params = {
        project_slug: 'test-project-88',
        resource_slug: 'samplepo',
        branch: 'master'
      }

      patch '/pull', params
      expect(last_response).to be_ok
    end
  end

  it 'verifies the push endpoint works' do
    VCR.use_cassette('push') do
      params = {
        project_slug: 'test-project-88',
        resource_slug: 'samplepo',
        branch: 'master'
      }

      patch '/push', params
      expect(last_response).to be_ok
    end
  end
end
