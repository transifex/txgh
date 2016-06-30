require 'spec_helper'
require 'helpers/github_payload_builder'
require 'rack/test'
require 'uri'


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
    Txgh::Config.new(second_project_config, second_repo_config, tx_config_multi_project)
  end

  before(:each) do
    allow(Txgh::KeyManager).to(
      receive(:config_from_project).with('my_second_awesome_project').and_return(config)
    )

    allow(Txgh::KeyManager).to(
      receive(:config_from_repo).with('my_org/my_second_repo').and_return(config)
    )
  end

  describe '/transifex' do
    let(:handler) { double(:handler) }

    it 'creates a handler and executes it' do
      expect(app).to(
        receive(:transifex_handler_for) do |options|
          expect(options[:project].name).to eq('my_second_awesome_project')
          expect(options[:repo].name).to eq('my_org/my_second_repo')
          handler
        end
      )

      expect(handler).to receive(:execute)

      params = {
        'project' => 'my_second_awesome_project',
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
          expect(options[:project].name).to eq('my_second_awesome_project')
          expect(options[:repo].name).to eq('my_org/my_second_repo')
          handler
        end
      )

      expect(handler).to receive(:execute)

      payload = GithubPayloadBuilder.webhook_payload('my_org/my_second_repo', ref)

      post '/github', {
        'payload' => payload.to_json
      }
    end
  end
end
