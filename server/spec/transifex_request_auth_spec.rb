require 'spec_helper'
require 'rack'

describe TxghServer::TransifexRequestAuth do
  let(:secret) { 'abc123' }
  let(:params) { { param1: 'value1', param2: 'value2', param3: 123 }.to_json }
  let(:date_str) { Time.now.strftime('%a, %d %b %Y %H:%M:%S GMT') }
  let(:http_verb) { 'POST' }
  let(:url) { 'http://example.com/transifex' }
  let(:valid_signature) do
    data = [http_verb, url, date_str, Digest::MD5.hexdigest(params)]
    Base64.encode64(
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, data.join("\n"))
    ).strip
  end

  describe '.authentic_request?' do
    it 'returns true if the request is signed correctly' do
      request = Rack::Request.new(
        described_class::RACK_HEADER => valid_signature,
        'HTTP_DATE' => date_str,
        'REQUEST_METHOD' => http_verb,
        'HTTP_X_TX_URL' => url,
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
      value = described_class.compute_signature(
        http_verb: http_verb,
        date_str: date_str,
        url: url,
        content: params,
        secret: secret
      )

      expect(value).to eq(valid_signature)
    end
  end
end
