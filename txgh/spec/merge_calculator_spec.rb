require 'spec_helper'

include Txgh

describe MergeCalculator do
  def phrase(key, string)
    { 'key' => key, 'string' => string }
  end

  let(:resource) do
    TxResource.new(
      'project_name', 'resource_slug', 'YAML',
      'en', 'en.yml', '', 'translation_file'
    )
  end

  let(:head_contents) do
    ResourceContents.from_phrase_list(resource, head_phrases)
  end

  let(:diff_point_contents) do
    ResourceContents.from_phrase_list(resource, diff_point_phrases)
  end

  let(:diff_hash) do
    head_contents.diff_hash(diff_point_contents)
  end

  let(:merge_result) do
    MergeCalculator.merge(head_contents, diff_point_contents, diff_hash)
  end

  context 'with phrases added to HEAD' do
    let(:diff_point_phrases) do
      [phrase('planet.earth', 'Human')]
    end

    let(:head_phrases) do
      diff_point_phrases + [
        phrase('planet.bajor', 'Bajoran')
      ]
    end

    it 'includes the added phrase' do
      expect(merge_result.phrases).to eq(head_phrases)
    end
  end

  context 'with an array added in HEAD' do
    let(:diff_point_phrases) do
      [phrase('planet.earth', 'Human')]
    end

    let(:head_phrases) do
      diff_point_phrases + [
        phrase('villains', %w(Kahn Chang Valeris Shinzon))
      ]
    end

    it 'includes the added array' do
      expect(merge_result.phrases).to eq(head_phrases)
    end
  end

  context 'with phrases removed from HEAD' do
    let(:diff_point_phrases) do
      head_phrases + [
        phrase('planet.bajor', 'Bajoran')
      ]
    end

    let(:head_phrases) do
      [phrase('planet.earth', 'Human')]
    end

    it 'does not include the removed phrase' do
      expect(merge_result.phrases).to eq(head_phrases)
    end
  end

  context 'with an array removed from HEAD' do
    let(:diff_point_phrases) do
      head_phrases + [
        phrase('villains', %w(Kahn Chang Valeris Shinzon))
      ]
    end

    let(:head_phrases) do
      [phrase('planet.earth', 'Human')]
    end

    it 'does not include the removed array' do
      expect(merge_result.phrases).to eq(head_phrases)
    end
  end

  context 'with phrases modified in HEAD' do
    let(:diff_point_phrases) do
      [phrase('planet.bajor', 'Cardassian')]
    end

    let(:head_phrases) do
      [phrase('planet.bajor', 'Bajoran')]
    end

    it 'includes the modified phrase' do
      expect(merge_result.phrases).to eq(head_phrases)
    end
  end

  context 'with an array modified in HEAD' do
    let(:diff_point_phrases) do
      [phrase('villains', %w(Kahn Chang Valeris))]
    end

    let(:head_phrases) do
      [phrase('villains', %w(Kahn Chang Valeris Shinzon))]
    end

    it 'includes the modified phrase' do
      expect(merge_result.phrases).to eq(head_phrases)
    end
  end

  context 'with no phrases modified, added, or removed' do
    let(:diff_point_phrases) do
      [phrase('planet.bajor', 'Bajoran')]
    end

    let(:head_phrases) do
      diff_point_phrases
    end

    it 'returns an unmodified set of phrases' do
      expect(merge_result.phrases).to eq(diff_point_phrases)
    end
  end

  context 'with an separately defined diff hash' do
    let(:diff_point_phrases) do
      [phrase('planet.earth', 'Human')]
    end

    let(:head_phrases) do
      diff_point_phrases + [
        phrase('planet.bajor', 'Bajoran')
      ]
    end

    let(:diff_hash) do
      { added: [], removed: [], modified: [] }
    end

    it 'respects the diff hash by returning an unmodified set of phrases' do
      expect(merge_result.phrases).to eq(diff_point_phrases)
    end
  end
end
