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
end
