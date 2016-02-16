require 'spec_helper'
require 'rack/test'
require 'uri'

require 'helpers/github_payload_builder'
require 'helpers/standard_txgh_setup'

describe Txgh::Application do
  include Rack::Test::Methods

  def app
    Txgh::Application
  end

  describe '/health_check' do
    it 'indicates the server is running, returns a 200' do
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
    Txgh::Config.new(project_config, repo_config)
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

describe Txgh::Triggers do
  include Rack::Test::Methods
  include StandardTxghSetup

  def app
    Txgh::Triggers
  end

  let(:config) do
    Txgh::Config.new(project_config, repo_config)
  end

  before(:each) do
    allow(Txgh::KeyManager).to(
      receive(:config_from_project).with(project_name).and_return(config)
    )

    allow(Txgh::KeyManager).to(
      receive(:config_from_repo).with(repo_name).and_return(config)
    )
  end

  describe '/push' do
    it 'updates the expected resource' do
      updater = double(:updater)
      expect(Txgh::ResourceUpdater).to receive(:new).and_return(updater)
      expect(Txgh::GithubApi).to receive(:new).and_return(github_api)
      expect(github_api).to receive(:get_ref).and_return(object: { sha: 'abc123' })

      expect(updater).to receive(:update_resource) do |resource, sha|
        expected_branch = Txgh::Utils.absolute_branch(branch)
        expect(resource.branch).to eq(expected_branch)
        expect(resource.project_slug).to eq(project_name)
        expect(resource.resource_slug).to(
          eq("#{resource_slug}-#{Txgh::Utils.slugify(expected_branch)}")
        )
      end

      patch '/push', {
        project_slug: project_name, resource_slug: resource_slug, branch: branch
      }

      expect(last_response).to be_ok
    end
  end

  describe '/pull' do
    it 'updates translations (in all locales) in the expected repo' do
      committer = double(:committer)
      languages = [{ 'language_code' => 'pt' }, { 'language_code' => 'ja' }]
      expect(Txgh::ResourceCommitter).to receive(:new).and_return(committer)
      expect(Txgh::TransifexApi).to receive(:new).and_return(transifex_api)
      expect(transifex_api).to receive(:get_languages).and_return(languages)

      languages.each do |language|
        expect(committer).to receive(:commit_resource) do |resource, branch, lang|
          expect(branch).to eq(branch)
          expect(lang).to eq(language['language_code'])
          expect(resource.branch).to eq(branch)
          expect(resource.project_slug).to eq(project_name)
          expect(resource.resource_slug).to(
            eq("#{resource_slug}-#{Txgh::Utils.slugify(branch)}")
          )
        end
      end

      patch '/pull', {
        project_slug: project_name, resource_slug: resource_slug, branch: branch
      }

      expect(last_response).to be_ok
    end
  end
end
