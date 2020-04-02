require 'spec_helper'
require 'helpers/standard_txgh_setup'

describe TxghServer::Webhooks::Github::StatusUpdater do
  include StandardTxghSetup

  let(:updater) { TxghServer::Webhooks::Github::StatusUpdater.new(transifex_project, github_repo, ref) }

  describe '#report_error_and_update_status' do
    let(:description) { 'An error done occurred, fool' }
    let(:target_url) { 'http://you-goofed.com' }

    let(:status_params) do
      { description: description, target_url: target_url }
    end

    let(:error_params) { { foo: 'bar' } }

    before(:each) do
      Txgh.events.subscribe(Txgh::Events::ERROR_CHANNEL) { error_params }
      Txgh.events.subscribe('github.status.error') { status_params }
    end

    it 'reports the error and updates the status' do
      expect(Txgh::GithubStatus).to(
        receive(:error).with(transifex_project, github_repo, ref, status_params)
      )

      expect(Txgh.events).to receive(:publish_error!)
      updater.report_error_and_update_status(StandardError.new)
    end

    it 'avoids blowing up on octokit error' do
      expect(Txgh::GithubStatus).to(
        receive(:error).and_raise(Octokit::UnprocessableEntity)
      )

      expect { updater.report_error_and_update_status(StandardError.new) }.to_not raise_error
    end
  end

  describe '#update_status' do
    it 'updates the github status' do
      expect(Txgh::GithubStatus).to receive(:update)
      updater.update_status
    end

    it 'avoids blowing up on octokit error' do
      expect(Txgh::GithubStatus).to(
        receive(:update).and_raise(Octokit::UnprocessableEntity)
      )

      expect { updater.update_status }.to_not raise_error
    end
  end
end
