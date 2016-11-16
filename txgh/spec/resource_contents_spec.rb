require 'spec_helper'
require 'stringio'

include Txgh

describe ResourceContents do
  let(:tx_resource) do
    TxResource.new(
      'project_slug', 'resource_slug', 'YAML',
      'en', 'source_file', {}, 'translation_file'
    )
  end

  let(:default_contents) do
    outdent(%Q(
      en:
        welcome:
          message: "Hello!"
        goodbye:
          message: "Goodbye!"
    ))
  end

  let(:array_contents) do
    outdent(%Q(
      en:
        captains:
        - "Janeway"
        - "Picard"
        - "Sisko"
        - "Kirk"
    ))
  end

  let(:contents) do
    ResourceContents.from_string(tx_resource, default_contents)
  end

  describe '#phrases' do
    it 'extracts phrases from the resource contents' do
      expect(contents.phrases).to eq([
        { 'key' => 'welcome.message', 'string' => 'Hello!' },
        { 'key' => 'goodbye.message', 'string' => 'Goodbye!' }
      ])
    end

    it 'preserves arrays' do
      rsrc_contents = ResourceContents.from_string(tx_resource, array_contents)
      expect(rsrc_contents.phrases).to eq([
        { 'key' => 'captains', 'string' => %w(Janeway Picard Sisko Kirk) }
      ])
    end
  end

  describe '#add' do
    it 'adds a new phrase' do
      contents.add('foo.bar', 'baz')
      expect(contents.phrases).to include(
        { 'key' => 'foo.bar', 'string' => 'baz' }
      )
    end
  end

  describe '#write_to' do
    it 'serializes the phrases to the given stream' do
      stream = StringIO.new
      contents.write_to(stream)
      expect(stream.string).to eq(default_contents)
    end

    it 'serializes arrays correctly' do
      stream = StringIO.new
      rsrc_contents = ResourceContents.from_string(tx_resource, array_contents)
      rsrc_contents.write_to(stream)
      expect(stream.string).to eq(array_contents)
    end

    it 'includes phrases that were added after the fact' do
      contents.add('foo.bar.baz', 'boo')

      stream = StringIO.new
      contents.write_to(stream)

      expect(stream.string).to eq(outdent(%Q(
        en:
          welcome:
            message: "Hello!"
          goodbye:
            message: "Goodbye!"
          foo:
            bar:
              baz: "boo"
      )))
    end
  end

  describe '#to_s' do
    it 'serializes to a string' do
      expect(contents.to_s).to eq(outdent(%Q(
        en:
          welcome:
            message: "Hello!"
          goodbye:
            message: "Goodbye!"
      )))
    end
  end

  describe '#empty?' do
    it 'returns true if the resource contains no phrases' do
      contents = ResourceContents.from_phrase_list(tx_resource, [])
      expect(contents).to be_empty
    end

    it 'returns false if the resource contains phrases' do
      expect(contents).to_not be_empty
    end
  end

  describe '#diff' do
    let(:head) do
      ResourceContents.from_string(tx_resource, head_contents)
    end

    let(:diff_point) do
      ResourceContents.from_string(tx_resource, diff_point_contents)
    end

    let(:diff) do
      head.diff(diff_point)
    end

    context 'with phrases added to HEAD' do
      let(:head_contents) do
        outdent(%Q(
          en:
            welcome:
              message: Hello!
            goodbye:
              message: Goodbye!
        ))
      end

      let(:diff_point_contents) do
        outdent(%Q(
          en:
            welcome:
              message: Hello!
        ))
      end

      it 'includes the added phrase' do
        expect(diff.phrases).to eq([
          { 'key' => 'goodbye.message', 'string' => 'Goodbye!' }
        ])
      end

      it 'returns an instance of ResourceContents' do
        expect(diff).to be_a(ResourceContents)
      end
    end

    context 'with phrases removed from HEAD' do
      let(:head_contents) do
        outdent(%Q(
          en:
            welcome: Hello
        ))
      end

      let(:diff_point_contents) do
        outdent(%Q(
          en:
            welcome: Hello
            goodbye: Goodbye
        ))
      end

      it 'does not include any phrases' do
        expect(diff.phrases).to eq([])
      end
    end

    context 'with phrases modified in HEAD' do
      let(:head_contents) do
        outdent(%Q(
          en:
            welcome: Hello world
            goodbye: Goodbye
        ))
      end

      let(:diff_point_contents) do
        outdent(%Q(
          en:
            welcome: Hello
            goodbye: Goodbye
        ))
      end

      it 'includes the modified phrase' do
        expect(diff.phrases).to eq([
          { 'key' => 'welcome', 'string' => 'Hello world' }
        ])
      end
    end

    context 'with no modifications or additions' do
      let(:head_contents) do
        outdent(%Q(
          en:
            welcome: Hello
            goodbye: Goodbye
        ))
      end

      let(:diff_point_contents) do
        outdent(%Q(
          en:
            welcome: Hello
            goodbye: Goodbye
        ))
      end

      it 'hands back an empty diff' do
        expect(diff.phrases).to eq([])
      end
    end

  end
end
