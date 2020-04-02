require 'spec_helper'

describe Txgh::TxResource do
  let(:resource) do
    described_class.new(
      'project_slug', 'resource_slug', 'type',
      'source_lang', 'source_file', { 'ko-KR' => 'ko' }, 'translation_file/<lang>.foo'
    )
  end

  describe '#lang_map' do
    it 'converts the given language if a mapping exists for it' do
      expect(resource.lang_map('ko-KR')).to eq('ko')
    end

    it 'does not perform any conversion if no mapping exists for the given language' do
      expect(resource.lang_map('foo')).to eq('foo')
    end
  end

  describe '#slugs' do
    it 'returns an array containing the project and resource slugs' do
      expect(resource.slugs).to eq(%w(project_slug resource_slug))
    end
  end

  describe '#translation_path' do
    it 'interpolates the given locale' do
      expect(resource.translation_path('de')).to eq('translation_file/de.foo')
    end

    it 'interpolates using the converted locale if a mapping exists for it' do
      expect(resource.translation_path('ko-KR')).to eq('translation_file/ko.foo')
    end
  end

  describe '#to_h' do
    it 'converts the resource into a hash' do
      expect(resource.to_h).to eq(
        project_slug: 'project_slug',
        resource_slug: 'resource_slug',
        type: 'type',
        source_lang: 'source_lang',
        source_file: 'source_file',
        translation_file: 'translation_file/<lang>.foo'
      )
    end
  end
end
