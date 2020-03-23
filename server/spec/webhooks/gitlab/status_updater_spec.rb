require 'spec_helper'
require 'helpers/standard_txgh_setup'

describe TxghServer::Webhooks::Gitlab::StatusUpdater do
  include StandardTxghSetup

  let(:updater) { TxghServer::Webhooks::Gitlab::StatusUpdater.new(transifex_project, gitlab_repo, ref) }
  let(:gitlab_error_response) do
    OpenStruct.new({
      code: 404,
      request: double(base_uri: 'https://gitlab.com/api/v3', path: '/foo'),
      parsed_response: ::Gitlab::ObjectifiedHash.new(
        error_description: 'Displayed error_description',
        error: 'also will not be displayed'
      )
    })
  end

  describe '#report_error_and_update_status' do
    let(:description) { 'An error done occurred, fool' }
    let(:target_url) { 'http://you-goofed.com' }

    let(:status_params) do
      { description: description, target_url: target_url }
    end

    let(:error_params) { { foo: 'bar' } }

    before(:each) do
      Txgh.events.subscribe(Txgh::Events::ERROR_CHANNEL) { error_params }
      Txgh.events.subscribe('gitlab.status.error') { status_params }
    end

    it 'reports the error and updates the status' do
      expect(Txgh::GitlabStatus).to(
        receive(:error).with(transifex_project, gitlab_repo, ref, status_params)
      )

      expect(Txgh.events).to receive(:publish_error!)
      updater.report_error_and_update_status(StandardError.new)
    end

    it 'avoids blowing up on gitlab error' do
      expect(Txgh::GitlabStatus).to(
        receive(:error).and_raise(::Gitlab::Error::BadRequest.new(gitlab_error_response))
      )

      expect { updater.report_error_and_update_status(StandardError.new) }.to_not raise_error
    end
  end

  describe '#update_status' do
    it 'updates the gitlab status' do
      expect(Txgh::GitlabStatus).to receive(:update)
      updater.update_status
    end

    it 'avoids blowing up on gitlab error' do
      expect(Txgh::GitlabStatus).to(
        receive(:update).and_raise(::Gitlab::Error::BadRequest.new(gitlab_error_response))
      )

      expect { updater.update_status }.to_not raise_error
    end
  end
end
