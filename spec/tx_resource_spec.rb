require 'spec_helper'

include Txgh

describe TxResource do
  let(:resource) do
    TxResource.new(
      'project_slug', 'resource_slug', 'type',
      'source_lang', 'source_file', 'ko-KR:ko', 'translation_file'
    )
  end

  describe '#L10N_resource_slug' do
    it 'appends L10N to the resource slug' do
      expect(resource.L10N_resource_slug).to eq("L10Nresource_slug")
    end
  end

  describe '#lang_map' do
    it 'converts the given language if a mapping exists for it' do
      expect(resource.lang_map('ko-KR')).to eq('ko')
    end

    it 'does not perform any conversion if no mapping exists for the given language' do
      expect(resource.lang_map('foo')).to eq('foo')
    end
  end
end
