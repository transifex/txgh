require 'spec_helper'

include Txgh

describe Utils do
  describe '.slugify' do
    it 'correctly slugifies a string with slashes' do
      expect(Utils.slugify('abc/def/ghi')).to eq('abc_def_ghi')
    end

    it 'does not replace underscores' do
      expect(Utils.slugify('abc_def/ghi')).to eq('abc_def_ghi')
    end

    it 'does not allow periods' do
      expect(Utils.slugify('abc/def-4.0.13')).to eq('abc_def-4013')
    end
  end

  describe '.absolute_branch' do
    it 'does not modify tags' do
      expect(Utils.absolute_branch('tags/foo')).to eq('tags/foo')
    end

    it 'does not modify heads' do
      expect(Utils.absolute_branch('heads/foo')).to eq('heads/foo')
    end

    it 'prefixes heads/ to bare branch names' do
      expect(Utils.absolute_branch('foo')).to eq('heads/foo')
    end

    it 'handles a nil branch' do
      expect(Utils.absolute_branch(nil)).to eq(nil)
    end
  end

  describe '.relative_branch' do
    it 'removes tags/ if present' do
      expect(Utils.relative_branch('tags/foobar')).to eq('foobar')
    end

    it 'removes heads/ if present' do
      expect(Utils.relative_branch('heads/foobar')).to eq('foobar')
    end

    it 'does nothing if no prefix can be removed' do
      expect(Utils.relative_branch('abcdef')).to eq('abcdef')
    end
  end

  describe '.is_tag?' do
    it 'returns true if given a tag' do
      expect(Utils.is_tag?('tags/foo')).to eq(true)
    end

    it 'returns false if not given a tag' do
      expect(Utils.is_tag?('heads/foo')).to eq(false)
      expect(Utils.is_tag?('foo')).to eq(false)
    end
  end

  describe '.git_hash_blob' do
    it 'calculates the git blob hash for the given string' do
      expect(Utils.git_hash_blob('foobarbaz')).to eq(
        '31e446dbb4751d2157c673a88826b3541ae073ea'
      )
    end
  end

  describe '.index_on' do
    it 'correctly converts an array of hashes' do
      arr = [
        { 'name' => 'Jean Luc Picard', 'starship' => 'Enterprise' },
        { 'name' => 'Kathryn Janeway', 'starship' => 'Voyager' }
      ]

      expect(Utils.index_on('starship', arr)).to eq({
        'Enterprise' => { 'name' => 'Jean Luc Picard', 'starship' => 'Enterprise' },
        'Voyager' => { 'name' => 'Kathryn Janeway', 'starship' => 'Voyager' }
      })
    end
  end

  describe '.booleanize' do
    it 'converts a string into a bool' do
      expect(Utils.booleanize('true')).to eq(true)
      expect(Utils.booleanize('false')).to eq(false)
    end

    it 'converts a badly-cased string into a bool' do
      expect(Utils.booleanize('TrUe')).to eq(true)
      expect(Utils.booleanize('faLSE')).to eq(false)
    end

    it "doesn't convert bools" do
      expect(Utils.booleanize(true)).to eq(true)
      expect(Utils.booleanize(false)).to eq(false)
    end
  end

  describe '.deep_symbolize_keys' do
    it 'symbolizes keys in a hash with depth 1' do
      hash = { 'abc' => 'def', ghi: 'jkl' }
      expect(Utils.deep_symbolize_keys(hash)).to eq(
        { abc: 'def', ghi: 'jkl' }
      )
    end

    it 'symbolizes keys in a hash with depth 2' do
      hash = { 'abc' => { 'def' => 'ghi' } }
      expect(Utils.deep_symbolize_keys(hash)).to eq(
        { abc: { def: 'ghi' } }
      )
    end

    it 'symbolizes keys in a hash with depth 3' do
      hash = { 'abc' => { 'def' => { 'ghi' => 'jkl' }, 'mno' => 'pqr' } }
      expect(Utils.deep_symbolize_keys(hash)).to eq(
        { abc: { def: { ghi: 'jkl' }, mno: 'pqr' } }
      )
    end

    it 'symbolizes hash keys in an array' do
      array = [{ 'def' => 'ghi' }]
      expect(Utils.deep_symbolize_keys(array)).to eq(
        [{ def: 'ghi' }]
      )
    end

    it 'symbolizes keys nested inside arrays' do
      hash = { 'abc' => [{ 'def' => 'ghi' }] }
      expect(Utils.deep_symbolize_keys(hash)).to eq(
        { abc: [{ def: 'ghi' }] }
      )
    end

    it "doesn't modify objects that aren't hashes" do
      hash = { 'abc' => Set.new(%w(a b c)) }
      expect(Utils.deep_symbolize_keys(hash)).to eq(
        { abc: hash['abc'] }
      )
    end
  end
end
