require 'spec_helper'
require 'rack'

include Txgh

describe TransifexRequestAuth do
  let(:secret) { 'abc123' }
  let(:formdata_params) { 'param1=value1&param2=value2&param3=123' }
  let(:json_params) { '{"param1": "value1", "param2": "value2", "param3": 123}' }
  let(:valid_signature_v1) { 'pXucIcivBezpfNgCGTHKYeDve84=' }
  let(:valid_signature_v2) { '6zZG2fkHKFlNTSmckWDa+wUEyhQkPAbhaTxjMiJf23c=' }
  let(:date) { 'Fri, 17 Feb 2017 08:24:07 GMT' }
  let(:http_verb) { 'POST' }
  let(:url) { 'http://www.transifex.com/' }

  describe '.authentic_request?' do
    it 'returns true if the request is signed correctly' do
      request = Rack::Request.new(
        TransifexRequestAuth::RACK_HEADER => valid_signature_v1,
        'rack.input' => StringIO.new(formdata_params)
      )

      authentic = TransifexRequestAuth.authentic_request?(request, secret)
      expect(authentic).to eq(true)
    end

    it 'returns false if the request is not signed correctly' do
      request = Rack::Request.new(
        TransifexRequestAuth::RACK_HEADER => 'incorrect',
        'rack.input' => StringIO.new(formdata_params)
      )

      authentic = TransifexRequestAuth.authentic_request?(request, secret)
      expect(authentic).to eq(false)
    end
  end

  describe '.header' do
    it 'calculates the V1 signature and formats it as an http header' do
      params = {:param1 => 'value1', :param2 => 'value2', :param3 => 123}
      value = TransifexRequestAuth.header_value_v1(params, secret)
      expect(value).to eq(valid_signature_v1)
    end

    it 'calculates the V2 signature and formats it as an http header' do
      url = 'http://www.transifex.com/'
      value = TransifexRequestAuth.header_value_v2(http_verb, url, date, json_params, secret)
      expect(value).to eq(valid_signature_v2)
    end
  end
end
