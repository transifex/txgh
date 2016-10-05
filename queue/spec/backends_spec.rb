require 'spec_helper'

include TxghQueue

describe Backends do
  describe '.register' do
    it 'associates the name of a backend with a class' do
      # use a string just for testing purposes; second argument should be a class
      described_class.register(:foo, 'BarClass')
      expect(described_class.all[:foo]).to eq('BarClass')
    end
  end

  describe '.get' do
    it 'retrieves the class for the given name' do
      described_class.register(:foo, 'BarClass')
      expect(described_class.get(:foo)).to eq('BarClass')
    end
  end

  describe '.all' do
    it 'returns a hash of all the name/class pairs' do
      described_class.register(:foo, 'BarClass')
      described_class.register(:baz, 'BooClass')

      expect(described_class.all).to include(
        foo: 'BarClass', baz: 'BooClass'
      )
    end
  end
end
