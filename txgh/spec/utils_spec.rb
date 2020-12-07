require 'spec_helper'

describe Txgh::Utils do
  describe '.slugify' do
    it 'correctly slugifies a string with slashes' do
      expect(described_class.slugify('abc/def/ghi')).to eq('abc_def_ghi')
    end

    it 'does not replace underscores' do
      expect(described_class.slugify('abc_def/ghi')).to eq('abc_def_ghi')
    end

    it 'does not allow periods' do
      expect(described_class.slugify('abc/def-4.0.13')).to eq('abc_def-4013')
    end
  end

  describe '.absolute_branch' do
    it 'does not modify tags' do
      expect(described_class.absolute_branch('tags/foo')).to eq('tags/foo')
    end

    it 'does not modify heads' do
      expect(described_class.absolute_branch('heads/foo')).to eq('heads/foo')
    end

    it 'prefixes heads/ to bare branch names' do
      expect(described_class.absolute_branch('foo')).to eq('heads/foo')
    end

    it 'handles a nil branch' do
      expect(described_class.absolute_branch(nil)).to eq(nil)
    end
  end

  describe '.relative_branch' do
    it 'removes tags/ if present' do
      expect(described_class.relative_branch('tags/foobar')).to eq('foobar')
    end

    it 'removes heads/ if present' do
      expect(described_class.relative_branch('heads/foobar')).to eq('foobar')
    end

    it 'does nothing if no prefix can be removed' do
      expect(described_class.relative_branch('abcdef')).to eq('abcdef')
    end
  end

  describe '.url_safe_relative_branch' do
    it 'removes tags/ if present' do
      expect(described_class.url_safe_relative_branch('tags/feature/foobar')).to eq('feature%2Ffoobar')
    end

    it 'removes heads/ if present' do
      expect(described_class.url_safe_relative_branch('heads/foobar')).to eq('foobar')
    end

    it 'does nothing if no prefix can be removed' do
      expect(described_class.url_safe_relative_branch('feature/JIRA-abcdef')).to eq('feature%2FJIRA-abcdef')
    end
  end

  describe '.is_tag?' do
    it 'returns true if given a tag' do
      expect(described_class.is_tag?('tags/foo')).to eq(true)
    end

    it 'returns false if not given a tag' do
      expect(described_class.is_tag?('heads/foo')).to eq(false)
      expect(described_class.is_tag?('foo')).to eq(false)
    end
  end

  describe '.git_hash_blob' do
    it 'calculates the git blob hash for the given string' do
      expect(described_class.git_hash_blob('foobarbaz')).to eq(
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

      expect(described_class.index_on('starship', arr)).to eq({
        'Enterprise' => { 'name' => 'Jean Luc Picard', 'starship' => 'Enterprise' },
        'Voyager' => { 'name' => 'Kathryn Janeway', 'starship' => 'Voyager' }
      })
    end
  end

  describe '.booleanize' do
    it 'converts a string into a bool' do
      expect(described_class.booleanize('true')).to eq(true)
      expect(described_class.booleanize('false')).to eq(false)
    end

    it 'converts a badly-cased string into a bool' do
      expect(described_class.booleanize('TrUe')).to eq(true)
      expect(described_class.booleanize('faLSE')).to eq(false)
    end

    it "doesn't convert bools" do
      expect(described_class.booleanize(true)).to eq(true)
      expect(described_class.booleanize(false)).to eq(false)
    end
  end
end
