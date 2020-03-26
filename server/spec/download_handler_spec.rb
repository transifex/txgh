require 'spec_helper'
require 'helpers/standard_txgh_setup'
require 'yaml'

describe TxghServer::DownloadHandler do
  include StandardTxghSetup

  let(:format) { described_class::DEFAULT_FORMAT }

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
      response = described_class.handle_request(request)
      expect(response).to be_streaming
      expect(response).to be_a(TxghServer::ZipStreamResponse)
      expect(response.attachment).to eq(project_name)
    end

    context 'with a tgz format specified' do
      let(:format) { '.tgz' }

      it 'responds with a streaming tgz download' do
        response = described_class.handle_request(request)
        expect(response).to be_streaming
        expect(response).to be_a(TxghServer::TgzStreamResponse)
      end
    end

    context 'when an error occurs' do
      before(:each) do
        expect(request).to receive(:params).and_raise(StandardError)
        response = described_class.handle_request(request)
        expect(response).to_not be_streaming
        expect(response.status).to eq(500)
      end
    end
  end

  context '#execute' do
    let(:handler) do
      described_class.new(transifex_project, github_repo, params, logger)
    end

    it 'responds with a streaming zip download' do
      expect(handler.execute).to be_a(TxghServer::ZipStreamResponse)
    end

    it 'responds with the project name as the attachment' do
      response = handler.execute
      expect(response.attachment).to eq(project_name)
    end

    context 'with a tgz format specified' do
      let(:format) { '.tgz' }

      it 'responds with a streaming tgz download' do
        expect(handler.execute).to be_a(TxghServer::TgzStreamResponse)
      end
    end

    context 'with a set of languages' do
      let(:supported_languages) { %w(is fr) }

      it "downloads translations for the project's supported languages" do
        allow(transifex_api).to receive(:download)
        files = handler.execute.enum.to_a.map(&:first)
        expect(files).to eq(%w(translations/is/sample.yml translations/fr/sample.yml))
      end
    end
  end
end
