require 'spec_helper'

include Txgh

# the YAML.loads here are used to strip off leading tabs and such

describe DiffContentCalculator do
  describe '.diff_between' do
    let(:resource) do
      TxResource.new(
        'project_slug', 'resource_slug', 'YAML',
        'en', 'source_file', '', 'translation_file'
      )
    end

    let(:diff) do
      DiffContentCalculator.diff_between(
        head_contents, diff_point_contents, resource
      )
    end

    context 'with phrases added to HEAD' do
      let(:head_contents) do
        YAML.load("|
          en:
            welcome:
              message: Hello!
            goodbye:
              message: Goodbye!
        ")
      end

      let(:diff_point_contents) do
        YAML.load("|
          en:
            welcome:
              message: Hello!
        ")
      end

      it 'includes the added phrase' do
        expect(diff).to eq(YAML.load(%Q(|
          en:
            goodbye:
              message: ! "Goodbye!"
        )))
      end
    end

    context 'with phrases removed from HEAD' do
      let(:head_contents) do
        YAML.load("|
          en:
            welcome: Hello
        ")
      end

      let(:diff_point_contents) do
        YAML.load("|
          en:
            welcome: Hello
            goodbye: Goodbye
        ")
      end

      it 'does not include any phrases (and returns nil)' do
        expect(diff).to eq(nil)
      end
    end

    context 'with phrases modified in HEAD' do
      let(:head_contents) do
        YAML.load("|
          en:
            welcome: Hello world
            goodbye: Goodbye
        ")
      end

      let(:diff_point_contents) do
        YAML.load("|
          en:
            welcome: Hello
            goodbye: Goodbye
        ")
      end

      it 'includes the modified phrase' do
        expect(diff).to eq(YAML.load(%Q(|
          en:
            welcome: ! "Hello world"
        )))
      end
    end

    context 'with no modifications or additions' do
      let(:head_contents) do
        YAML.load("|
          en:
            welcome: Hello
            goodbye: Goodbye
        ")
      end

      let(:diff_point_contents) do
        YAML.load("|
          en:
            welcome: Hello
            goodbye: Goodbye
        ")
      end

      it 'includes the modified phrase' do
        expect(diff).to eq(nil)
      end
    end

  end
end
