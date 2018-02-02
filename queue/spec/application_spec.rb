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
      payload = params.to_json
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
        TxghServer::GithubRequestAuth.compute_signature(
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
