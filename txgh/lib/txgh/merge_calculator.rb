module Txgh
  class MergeCalculator
    class << self
      def merge(head_contents, diff_point_contents, diff_hash)
        new(head_contents, diff_point_contents, diff_hash).merge
      end
    end

    attr_reader :head_contents, :diff_point_contents, :diff_hash

    # Merges are based on diffs. Whatever was added/removed/modified between
    # two resources is represented by the diff, while the resources themselves
    # are what gets merged. This class uses the given diff to apply one
    # resource's phrases over the top of another.
    #
    # head_contents: translated contents in HEAD
    # diff_point_contents: translated contents in diff point, eg. master
    # diff_hash: what was added/removed/modified in the source
    def initialize(head_contents, diff_point_contents, diff_hash)
      @head_contents = head_contents
      @diff_point_contents = diff_point_contents
      @diff_hash = diff_hash
    end

    def merge
      phrase_hash = diff_point_hash.dup
      update_added(phrase_hash)
      update_modified(phrase_hash)
      update_removed(phrase_hash)

      ResourceContents.from_phrase_list(
        head_contents.tx_resource, phrase_hash.values
      )
    end

    private

    def update_added(phrase_hash)
      diff.fetch(:added, {}).each_pair do |key, phrase|
        if val = head_hash[key]
          phrase_hash[key] = val
        end
      end
    end

    def update_modified(phrase_hash)
      diff.fetch(:modified, {}).each_pair do |key, phrase|
        if val = head_hash[key]
          phrase_hash[key] = val
        end
      end
    end

    def update_removed(phrase_hash)
      diff.fetch(:removed, {}).each_pair do |key, _|
        phrase_hash.delete(key)
      end
    end

    def diff
      @diff ||= diff_hash.each_with_object({}) do |(status, phrases), ret|
        ret[status] = Utils.index_on('key', phrases)
      end
    end

    def head_hash
      head_contents.to_h
    end

    def diff_point_hash
      diff_point_contents.to_h
    end
  end
end
