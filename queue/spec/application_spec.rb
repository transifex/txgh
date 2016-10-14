require 'spec_helper'
require 'rack/test'

require 'helpers/github_payload_builder'
require 'helpers/standard_txgh_setup'

describe TxghQueue::WebhookEndpoints, auto_configure: true do
  include Rack::Test::Methods
  include StandardTxghSetup
  include TxghServer::ResponseHelpers

  def app
    TxghQueue::WebhookEndpoints
  end

  let(:config) do
    Txgh::Config::ConfigPair.new(project_config, repo_config)
  end

  let(:backend) { TxghQueue::Config.backend }

  describe '/transifex/enqueue' do
    def sign_with(body)
      header(
        TxghServer::TransifexRequestAuth::TRANSIFEX_HEADER,
        TxghServer::TransifexRequestAuth.header_value(
          body, config.transifex_project.webhook_secret
        )
      )
    end

    let(:producer) { backend.producer_for('transifex.hook') }
    let(:params) do
      {
        'project' => project_name,
        'resource' => resource_slug,
        'language' => language,
        'translated' => '100'
      }
    end

    it 'enqueues a new job' do
      payload = URI.encode_www_form(params.to_a)
      sign_with payload

      expect { post '/transifex/enqueue', payload }.to(
        change { producer.enqueued_jobs.size }.from(0).to(1)
      )

      expect(last_response).to be_accepted

      job = producer.enqueued_jobs.first
      expect(job[:payload]).to include(
        project: project_name,
        resource: resource_slug,
        language: language,
        translated: '100',
        txgh_event: 'transifex.hook'
      )
    end
  end

  describe '/github/enqueue' do
    def sign_with(body)
      header(
        TxghServer::GithubRequestAuth::GITHUB_HEADER,
        TxghServer::GithubRequestAuth.header_value(
          body, config.github_repo.webhook_secret
        )
      )
    end

    let(:producer) { backend.producer_for('github.push') }

    it 'enqueues a new job' do
      payload = GithubPayloadBuilder.push_payload(repo_name, ref)
      payload.add_commit

      sign_with payload.to_json
      header 'X-GitHub-Event', 'push'

      expect { post '/github/enqueue', payload.to_json }.to(
        change { producer.enqueued_jobs.size }.from(0).to(1)
      )

      expect(last_response).to be_accepted

      job = producer.enqueued_jobs.first
      expect(job[:payload]).to include(
        event: 'push',
        txgh_event: 'github.push',
        repo_name: repo_name,
        ref: "refs/#{ref}"
      )
    end
  end
end
