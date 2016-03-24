require 'abroad'
require 'stringio'

module Txgh
  class DiffContentCalculator
    EXTRACTOR_MAP = {
      'YML'          => 'yaml/rails',
      'YAML'         => 'yaml/rails',
      'JSONKEYVALUE' => 'json/key-value',
      'ANDROID'      => 'xml/android'
    }

    SERIALIZER_MAP = {
      'YML'          => 'yaml/rails',
      'YAML'         => 'yaml/rails',
      'JSONKEYVALUE' => 'json/key-value',
      'ANDROID'      => 'xml/android'
    }

    class << self
      def diff_between(head_contents, diff_point_contents, tx_resource)
        new(head_contents, diff_point_contents, tx_resource).diff
      end
    end

    attr_reader :head_contents, :diff_point_contents, :tx_resource

    def initialize(head_contents, diff_point_contents, tx_resource)
      @tx_resource = tx_resource
      @head_contents = head_contents
      @diff_point_contents = diff_point_contents
    end

    def diff
      all_phrases = compare_contents
      phrases = all_phrases[:added] + all_phrases[:modified]
      serialize(phrases) if phrases.size > 0
    end

    private

    def compare_contents
      head_phrases = extract_from(head_contents)
      diff_point_phrases = extract_from(diff_point_contents)
      DiffCalculator.compare(head_phrases, diff_point_phrases)
    end

    def extract_from(content)
      extractor.from_string(content) do |extractor|
        extractor.extract_each.map do |key, value|
          { 'key' => key, 'string' => value }
        end
      end
    end

    def serialize(phrases)
      stream = StringIO.new

      serializer.from_stream(stream, tx_resource.source_lang) do |serializer|
        phrases.each do |phrase|
          serializer.write_key_value(phrase['key'], phrase['string'])
        end
      end

      stream.string
    end

    def extractor
      id = EXTRACTOR_MAP.fetch(tx_resource.type) do
        raise TxghInternalError,
          "'#{tx_resource.type}' is not a file type that is supported when "\
          "uploading diffs."
      end

      Abroad.extractor(id)
    end

    def serializer
      id = SERIALIZER_MAP.fetch(tx_resource.type) do
        raise TxghInternalError,
          "'#{tx_resource.type}' is not a file type that is supported when "\
          "uploading diffs."
      end

      Abroad.serializer(id)
    end
  end
end
