require 'spec_helper'

include TxghQueue

describe Job, auto_configure: true do
  let(:logger) { NilLogger.new }
  let(:repo_name) { 'my_repo' }
  let(:txgh_config) { Txgh::Config::ConfigPair.new(:git_repo, :transifex_project) }
  let(:job) { described_class.new(logger) }

  before(:each) do
    allow(Txgh::Config::KeyManager).to(
      receive(:config_from_repo).with(repo_name).and_return(txgh_config)
    )
  end

  shared_examples 'a payload processor' do
    it 'processes the payload' do
      server_response = TxghServer::Response.new(200, 'Ok')
      expect(handler).to receive(:execute).and_return(server_response)
      result = job.process(payload)
      expect(result.status).to eq(Status.ok)
      expect(result.response).to eq(server_response)
    end

    it 'responds appropriately when an error is raised' do
      expect(handler).to receive(:execute).and_raise(StandardError)
      result = job.process(payload)
      expect(result.status).to eq(Status.fail)
      expect(result.error).to be_a(StandardError)
    end

    it 'responds appropriately when an error response is returned' do
      server_response = TxghServer::Response.new(404, 'Not found')
      expect(handler).to receive(:execute).and_return(server_response)
      result = job.process(payload)
      expect(result.status).to eq(Status.fail)
      expect(result.response).to eq(server_response)
    end
  end

  context 'with a push payload' do
    let(:payload) do
      {
        'repo_name' => repo_name,
        'event' => 'push',
        'txgh_event' => 'github.push',
        'ref' => 'heads/master',
        'before' => 'abc123',
        'after' => 'def456',
        'added_files' => [],
        'modified_files' => [],
        'author' => 'Bugs Bunny'
      }
    end

    describe '#process' do
      let(:handler) { double(:handler) }

      before(:each) do
        expect(TxghServer::Webhooks::Github::PushHandler).to(
          receive(:new).and_return(handler)
        )
      end

      it_behaves_like 'a payload processor'
    end
  end

  context 'with a delete payload' do
    let(:payload) do
      {
        'repo_name' => repo_name,
        'event' => 'delete',
        'txgh_event' => 'github.delete',
        'ref' => 'heads/master',
        'ref_type' => 'branch'
      }
    end

    describe '#process' do
      let(:handler) { double(:handler) }

      before(:each) do
        expect(TxghServer::Webhooks::Github::DeleteHandler).to(
          receive(:new).and_return(handler)
        )
      end

      it_behaves_like 'a payload processor'
    end
  end

  context 'with a payload with an unrecognized event type' do
    let(:payload) do
      {
        'repo_name' => repo_name,
        'txgh_event' => 'foobarbazboo'
      }
    end

    describe '#process' do
      it 'responds with fail' do
        result = job.process(payload)
        expect(result.status).to eq(Status.fail)
        expect(result.response.status).to eq(400)
        expect(result.response.body).to eq([error: 'Unexpected event type'])
      end
    end
  end
end
