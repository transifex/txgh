require 'spec_helper'
require 'helpers/standard_txgh_setup'
require 'yaml'

include Txgh::Handlers

describe DownloadHandler do
  include StandardTxghSetup

  let(:format) { DownloadHandler::DEFAULT_FORMAT }

  let(:params) do
    {
      'format' => format,
      'project_slug' => project_name,
      'branch' => ref
    }
  end

  context '.handle_request' do
    let(:request) do
      double(:request).tap do |dbl|
        allow(dbl).to receive(:params).and_return(params)
        allow(dbl).to receive(:env).and_return(env)
      end
    end

    let(:env) do
      { 'REQUEST_PATH' => "path/to/#{project_name}#{format}" }
    end

    it 'responds with a streaming zip and has the project name as the attachment' do
      response = DownloadHandler.handle_request(request)
      expect(response).to be_streaming
      expect(response).to be_a(ZipStreamResponse)
      expect(response.attachment).to eq(project_name)
    end

    context 'with a tgz format specified' do
      let(:format) { '.tgz' }

      it 'responds with a streaming tgz download' do
        response = DownloadHandler.handle_request(request)
        expect(response).to be_streaming
        expect(response).to be_a(TgzStreamResponse)
      end
    end

    context 'when an error occurs' do
      before(:each) do
        expect(request).to receive(:params).and_raise(StandardError)
        response = DownloadHandler.handle_request(request)
        expect(response).to_not be_streaming
        expect(response.status).to eq(500)
      end
    end
  end

  context '#execute' do
    let(:handler) do
      DownloadHandler.new(transifex_project, github_repo, params, logger)
    end

    it 'responds with a streaming zip download' do
      expect(handler.execute).to be_a(ZipStreamResponse)
    end

    it 'responds with the project name as the attachment' do
      response = handler.execute
      expect(response.attachment).to eq(project_name)
    end

    context 'with a tgz format specified' do
      let(:format) { '.tgz' }

      it 'responds with a streaming tgz download' do
        expect(handler.execute).to be_a(TgzStreamResponse)
      end
    end
  end
end
