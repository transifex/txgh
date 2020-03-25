require 'spec_helper'

describe Txgh::CategorySupport do
  describe '.deserialize_categories' do
    it 'converts an array of categories into a hash' do
      categories = %w(captain:janeway commander:chakotay)
      result = described_class.deserialize_categories(categories)
      expect(result).to eq('captain' => 'janeway', 'commander' => 'chakotay')
    end

    it 'converts an array of space-separated categories' do
      categories = ['captain:janeway commander:chakotay']
      result = described_class.deserialize_categories(categories)
      expect(result).to eq('captain' => 'janeway', 'commander' => 'chakotay')
    end
  end

  describe '.serialize_categories' do
    it 'converts a hash of categories into an array' do
      categories = { 'captain' => 'janeway', 'commander' => 'chakotay' }
      result = described_class.serialize_categories(categories)
      expect(result.sort).to eq(['captain:janeway', 'commander:chakotay'])
    end
  end

  describe '.escape_category' do
    it 'replaces spaces in category values' do
      expect(described_class.escape_category('Katherine Janeway')).to(
        eq('Katherine_Janeway')
      )
    end
  end

  describe '.join_categories' do
    it 'joins an array of categories by spaces' do
      expect(described_class.join_categories(%w(foo:bar baz:boo))).to(
        eq('foo:bar baz:boo')
      )
    end
  end
end
