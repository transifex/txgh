require 'spec_helper'

describe Txgh::DiffCalculator do
  def phrase(key, string)
    { 'key' => key, 'string' => string }
  end

  describe '.compare' do
    let(:diff) do
      described_class.compare(head_phrases, diff_point_phrases)
    end

    context 'with phrases added to HEAD' do
      let(:head_phrases) do
        diff_point_phrases + [
          phrase('TheNextGeneration', 'Jean Luc Picard')
        ]
      end

      let(:diff_point_phrases) do
        [
          phrase('Voyager', 'Kathryn Janeway'),
          phrase('DeepSpaceNine', 'Benjamin Sisko'),
        ]
      end

      it 'includes the new string' do
        expect(diff[:added].size).to eq(1)
        expect(diff[:modified].size).to eq(0)
        phrase = diff[:added].first
        expect(phrase['key']).to eq('TheNextGeneration')
        expect(phrase['string']).to eq('Jean Luc Picard')
      end
    end

    context 'with an array added to HEAD' do
      let(:head_phrases) do
        diff_point_phrases + [
          phrase('villains', %w(Khan Chang Valeris Shinzon))
        ]
      end

      let(:diff_point_phrases) do
        [
          phrase('Bajor', 'Bajoran'),
          phrase('Cardassia', 'Cardassian')
        ]
      end

      it 'includes the new array' do
        expect(diff[:added].size).to eq(1)
        expect(diff[:modified].size).to eq(0)
        phrase = diff[:added].first
        expect(phrase['key']).to eq('villains')
        expect(phrase['string']).to eq(%w(Khan Chang Valeris Shinzon))
      end
    end

    context 'with phrases removed from HEAD' do
      let(:head_phrases) do
        []
      end

      let(:diff_point_phrases) do
        [phrase('Voyager', 'Kathryn Janeway')]
      end

      it 'does not include the new string if string has been removed' do
        expect(diff[:added].size).to eq(0)
        expect(diff[:modified].size).to eq(0)
      end
    end

    context 'with an array removed from HEAD' do
      let(:head_phrases) do
        []
      end

      let(:diff_point_phrases) do
        phrase('villains', %w(Khan Chang Valeris Shinzon))
      end

      it 'does not include the array' do
        expect(diff[:added].size).to eq(0)
        expect(diff[:modified].size).to eq(0)
      end
    end

    context 'with phrases modified in HEAD' do
      let(:head_phrases) do
        [phrase('TheNextGeneration', 'Jean Luc Picard (rocks)')]
      end

      let(:diff_point_phrases) do
        [phrase('TheNextGeneration', 'Jean Luc Picard')]
      end

      it 'includes the modified string' do
        expect(diff[:added].size).to eq(0)
        expect(diff[:modified].size).to eq(1)
        phrase = diff[:modified].first
        expect(phrase['key']).to eq('TheNextGeneration')
        expect(phrase['string']).to eq('Jean Luc Picard (rocks)')
      end
    end

    context 'with an array modified in HEAD' do
      let(:head_phrases) do
        [phrase('villains', %w(Khan Chang Valeris Shinzon))]
      end

      let(:diff_point_phrases) do
        [phrase('villains', %w(Khan Chang Valeris))]
      end

      it 'includes the entire array' do
        expect(diff[:added].size).to eq(0)
        expect(diff[:modified].size).to eq(1)
        phrase = diff[:modified].first
        expect(phrase['key']).to eq('villains')
        expect(phrase['string']).to eq(%w(Khan Chang Valeris Shinzon))
      end
    end

    context 'with no phrases modified, added, or removed' do
      let(:head_phrases) do
        [
          phrase('TheNextGeneration', 'Jean Luc Picard'),
          phrase('Voyager', 'Kathryn Janeway'),
          phrase('DeepSpaceNine', 'Benjamin Sisko')
        ]
      end

      let(:diff_point_phrases) do
        head_phrases
      end

      it 'does not include any phrases' do
        expect(diff[:added].size).to eq(0)
        expect(diff[:modified].size).to eq(0)
      end
    end
  end
end
