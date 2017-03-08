require 'spec_helper'
require 'rack'

include Txgh

describe TransifexRequestAuth do
  let(:secret) { 'abc123' }
  let(:params) { 'param1=value1&param2=value2&param3=123' }
  let(:valid_signature) { 'pXucIcivBezpfNgCGTHKYeDve84=' }

  describe '.authentic_request?' do
    it 'returns true if the request is signed correctly' do
      request = Rack::Request.new(
        TransifexRequestAuth::RACK_HEADER => valid_signature,
        'rack.input' => StringIO.new(params)
      )

      authentic = TransifexRequestAuth.authentic_request?(request, secret)
      expect(authentic).to eq(true)
    end

    it 'returns false if the request is not signed correctly' do
      request = Rack::Request.new(
        TransifexRequestAuth::RACK_HEADER => 'incorrect',
        'rack.input' => StringIO.new(params)
      )

      authentic = TransifexRequestAuth.authentic_request?(request, secret)
      expect(authentic).to eq(false)
    end
  end

  describe '.header' do
    it 'calculates the signature and formats it as an http header' do
      params = {:param1 => 'value1', :param2 => 'value2', :param3 => 123}
      value = TransifexRequestAuth.header_value(params, secret)
      expect(value).to eq(valid_signature)
    end
  end
end
