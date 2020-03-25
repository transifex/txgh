require 'spec_helper'
require 'helpers/test_provider'

describe Txgh::Config::ProviderInstance do
  let(:provider) { TestProvider }
  let(:payload) { :fake_payload }
  let(:parser) { :fake_parser }
  let(:options) { :fake_options }
  let(:instance) { described_class.new(provider, parser) }

  describe '#supports?' do
    it 'returns true if the scheme matches' do
      expect(instance.supports?('test')).to eq(true)
    end

    it "returns false if the scheme doesn't match" do
      expect(instance.supports?('foo')).to eq(false)
    end
  end

  describe '#default' do
    it 'returns false if not the default provider' do
      expect(instance).to_not be_default
    end

    context 'with a default provider' do
      let(:instance) { described_class.new(provider, parser, default: true) }

      it 'returns true if marked as the default provider' do
        expect(instance).to be_default
      end
    end
  end

  describe '#load' do
    it "calls the provider's load method passing the parser and options" do
      expect(provider).to receive(:load).with(payload, parser, options)
      instance.load(payload, options)
    end
  end
end
