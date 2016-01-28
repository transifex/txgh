require 'spec_helper'
require 'helpers/github_payload_builder'
require 'rack/test'
require 'uri'

describe Txgh::Application do
  include Rack::Test::Methods

  def app
    Txgh::Application
  end

  describe '/health_check' do
    xit 'does not allow requests with no credentials' do
      get '/health_check'
      expect(last_response.status).to eq(401)
    end

    xit 'does not allow invalid credentials' do
      authorize 'bad', 'wrong'
      get '/health_check'
      expect(last_response.status).to eq(401)
    end

    it 'indicates the server is running, returns a 200' do
      authorize 'foo', 'bar'
      get '/health_check'
      expect(last_response).to be_ok
      expect(last_response.body).to be_empty
    end
  end
end

describe Txgh::Hooks do
  include Rack::Test::Methods
  include StandardTxghSetup

  def app
    # this insanity is necessary to allow the tests to stub helper methods
    @app ||= Class.new(Txgh::Hooks) do
      def call(env)
        # don't let sinatra dup us before calling
        call!(env)
      end
    end.new!  # new bang gives us a raw instance (Sinatra redefines `new`)
  end

  let(:config) do
    Txgh::Config.new(project_config, repo_config, tx_config)
  end

  before(:each) do
    allow(Txgh::KeyManager).to(
      receive(:config_from_project).with(project_name).and_return(config)
    )

    allow(Txgh::KeyManager).to(
      receive(:config_from_repo).with(repo_name).and_return(config)
    )
  end

  describe '/transifex' do
    let(:handler) { double(:handler) }

    it 'creates a handler and executes it' do
      expect(app).to(
        receive(:transifex_handler_for) do |options|
          expect(options[:project].name).to eq(project_name)
          expect(options[:repo].name).to eq(repo_name)
          handler
        end
      )

      expect(handler).to receive(:execute)

      params = {
        'project' => project_name,
        'resource' => resource_slug,
        'language' => language,
        'translated' => '100'
      }

      payload = URI.encode_www_form(params.to_a)
      post '/transifex', payload
    end
  end

  describe '/github' do
    let(:handler) { double(:handler) }

    it 'creates a handler and executes it' do
      expect(app).to(
        receive(:github_handler_for) do |options|
          expect(options[:project].name).to eq(project_name)
          expect(options[:repo].name).to eq(repo_name)
          handler
        end
      )

      expect(handler).to receive(:execute)

      payload = GithubPayloadBuilder.webhook_payload(repo_name, ref)

      post '/github', {
        'payload' => payload.to_json
      }
    end
  end
end
