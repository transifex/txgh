require 'spec_helper'
require 'rack'

include TxghServer

describe GitlabRequestAuth do
  let(:secret) { 'abc123' }

  describe '.authentic_request?' do
    it 'returns true if the request is signed correctly' do
      request = Rack::Request.new(
        GitlabRequestAuth::RACK_HEADER => secret
      )

      authentic = GitlabRequestAuth.authentic_request?(request, secret)
      expect(authentic).to eq(true)
    end

    it 'returns false if the request is not signed correctly' do
      request = Rack::Request.new(
        GitlabRequestAuth::RACK_HEADER => 'incorrect'
      )

      authentic = GitlabRequestAuth.authentic_request?(request, secret)
      expect(authentic).to eq(false)
    end
  end
end
