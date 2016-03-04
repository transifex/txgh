require 'spec_helper'
require 'helpers/test_provider'

include Txgh
include Txgh::Config

describe ProviderInstance do
  let(:provider) { TestProvider }
  let(:payload) { :fake_payload }
  let(:parser) { :fake_parser }
  let(:options) { :fake_options }
  let(:instance) { ProviderInstance.new(provider, parser) }

  describe '#supports?' do
    it 'returns true if the scheme matches' do
      expect(instance.supports?('test')).to eq(true)
    end

    it "returns false if the scheme doesn't match" do
      expect(instance.supports?('foo')).to eq(false)
    end
  end

  describe '#load' do
    it "calls the provider's load method passing the parser and options" do
      expect(provider).to receive(:load).with(payload, parser, options)
      instance.load(payload, options)
    end
  end
end
