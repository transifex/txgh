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

  describe '.is_tag?' do
    it 'returns true if given a tag' do
      expect(Utils.is_tag?('tags/foo')).to eq(true)
    end

    it 'returns false if not given a tag' do
      expect(Utils.is_tag?('heads/foo')).to eq(false)
      expect(Utils.is_tag?('foo')).to eq(false)
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
end
