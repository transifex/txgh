require 'abroad'
require 'stringio'

module Txgh
  class ResourceContents
    EXTRACTOR_MAP = {
      'YML'          => 'yaml/rails',
      'YAML'         => 'yaml/rails',
      'KEYVALUEJSON' => 'json/key-value',
      'ANDROID'      => 'xml/android'
    }

    SERIALIZER_MAP = {
      'YML'          => 'yaml/rails',
      'YAML'         => 'yaml/rails',
      'KEYVALUEJSON' => 'json/key-value',
      'ANDROID'      => 'xml/android'
    }

    class << self
      def from_phrase_list(tx_resource, phrases)
        new(tx_resource, phrases: phrases)
      end

      def from_string(tx_resource, string)
        new(tx_resource, raw: string)
      end
    end

    attr_reader :tx_resource

    def initialize(tx_resource, options)
      @tx_resource = tx_resource
      @phrases = options[:phrases]
      @raw = options[:raw]
    end

    def phrases
      @phrases ||= extractor.from_string(raw) do |extractor|
        extractor.extract_each(preserve_arrays: true).map do |key, value|
          { 'key' => key, 'string' => value }
        end
      end
    end

    def add(key, value)
      phrases << { 'key' => key, 'string' => value }
    end

    # Some formats like Rails YAML require the language to be written somewhere
    # in the file. If you're using this class to parse and serialize the
    # contents of a translated version of a resource, then you'll probably
    # want to override the resource's source language using the second
    # parameter here.
    def write_to(stream, language = tx_resource.source_lang)
      serializer.from_stream(stream, language) do |serializer|
        phrases.each do |phrase|
          serializer.write_key_value(
            phrase['key'], str(phrase['string'] || '')
          )
        end
      end
    end

    # see comment above write_to
    def to_s(language = tx_resource.source_lang)
      stream = StringIO.new
      write_to(stream, language)
      stream.string
    end

    def to_h
      Utils.index_on('key', phrases)
    end

    def diff(other_contents)
      diff = diff_hash(other_contents)
      diff_phrases = diff[:added] + diff[:modified]
      self.class.from_phrase_list(tx_resource, diff_phrases)
    end

    def diff_hash(other_contents)
      DiffCalculator.compare(phrases, other_contents.phrases)
    end

    def merge(other_contents, diff_hash)
      MergeCalculator.merge(other_contents, self, diff_hash)
    end

    def empty?
      phrases.empty?
    end

    private

    attr_reader :raw

    def str(obj)
      case obj
        when Array
          obj
        else
          obj.to_s
      end
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
