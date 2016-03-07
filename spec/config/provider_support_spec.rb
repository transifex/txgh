require 'spec_helper'
require 'helpers/test_provider'

include Txgh
include Txgh::Config

describe ProviderSupport do
  let(:klass) do
    Class.new { extend ProviderSupport }
  end

  let(:provider) { TestProvider }

  describe '#register_provider' do
    it 'adds an instance to the provider list' do
      expect { klass.register_provider(:fake_provider, :fake_parser) }.to(
        change { klass.providers.size }.by(1)
      )

      instance = klass.providers.first
      expect(instance.provider).to eq(:fake_provider)
      expect(instance.parser).to eq(:fake_parser)
    end
  end

  describe '#provider_for' do
    it 'returns nil if no provider can be found' do
      expect(klass.provider_for('foo')).to be_nil
    end
  end

  describe '#split_uri' do
    it 'separates the scheme and payload' do
      expect(klass.split_uri('foo://bar')).to eq(%w(foo bar))
    end

    it 'determines that the scheme is nil if not given' do
      expect(klass.split_uri('bar')).to eq([nil, 'bar'])
    end
  end

  context 'with a registered provider' do
    before(:each) do
      klass.register_provider(provider, :fake_parser)
    end

    describe '#provider_for' do
      it 'finds the first provider that matches the given scheme' do
        instance = klass.provider_for('test')
        expect(instance.provider).to eq(provider)
        expect(instance.parser).to eq(:fake_parser)
      end
    end
  end
end
