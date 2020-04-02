require 'spec_helper'
require 'rack'

describe TxghServer::GithubRequestAuth do
  let(:secret) { 'abc123' }
  let(:params) { '{"param1":"value1","param2":"value2","param3":123}' }
  let(:valid_signature) { 'ea62c3f65c8e42f155d96a25b7ba6eb5d320630e' }

  describe '.authentic_request?' do
    it 'returns true if the request is signed correctly' do
      request = Rack::Request.new(
        described_class::RACK_HEADER => "sha1=#{valid_signature}",
        'rack.input' => StringIO.new(params)
      )

      authentic = described_class.authentic_request?(request, secret)
      expect(authentic).to eq(true)
    end

    it 'returns false if the request is not signed correctly' do
      request = Rack::Request.new(
        described_class::RACK_HEADER => 'incorrect',
        'rack.input' => StringIO.new(params)
      )

      authentic = described_class.authentic_request?(request, secret)
      expect(authentic).to eq(false)
    end
  end

  describe '.compute_signature' do
    it 'calculates the signature and formats it as an http header' do
      value = described_class.compute_signature(params, secret)
      expect(value).to eq("sha1=#{valid_signature}")
    end
  end
end
