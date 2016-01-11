# encoding: UTF-8

require 'spec_helper'
require 'rack/test'

describe Txgh::Hooks do
  include Rack::Test::Methods

  def app
    Txgh::Hooks
  end

  describe '/transifex' do
    let(:project) { 'testing-20' }
    let(:resource) { 'samplepo' }
    let(:language) { 'el_GR' }

    let(:request_params) do
      {
        'project' => project,
        'resource' => resource,
        'language' => language,
        'translated' => 100
      }
    end

    it 'correctly processes a request from transifex' do
      # VCR.use_cassette('transifex_hook') do
      #   post '/transifex', request_params
      #   expect(last_response).to be_ok
      # end
    end
  end
end
