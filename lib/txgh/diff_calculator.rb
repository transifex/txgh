module Txgh
  class DiffCalculator
    class << self
      def compare(head_phrases, diff_point_phrases)
        new(head_phrases, diff_point_phrases).compare
      end
    end

    attr_reader :head_phrases, :diff_point_phrases

    def initialize(head_phrases, diff_point_phrases)
      @head_phrases = head_phrases
      @diff_point_phrases = diff_point_phrases
    end

    def compare
      join_diffs(compare_head, compare_diff_point)
    end

    private

    def join_diffs(diff1, diff2)
      [:added, :removed, :modified].each_with_object({}) do |state, ret|
        ret[state] = diff1[state] + diff2[state]
      end
    end

    def compare_head
      Hash.new { |hash, key| hash[key] = [] }.tap do |diff|
        head_to_diff_point.each do |phrase, state, old_phrase|
          diff[state] << DiffEntry.new(phrase, state, old_phrase)
        end
      end
    end

    def compare_diff_point
      Hash.new { |hash, key| hash[key] = [] }.tap do |diff|
        diff_point_to_head.each do |phrase, state, old_phrase|
          diff[state] << DiffEntry.new(phrase, state, old_phrase)
        end
      end
    end

    # identifies phrases in head that:
    #   are not in diff point ('added')
    #   have the same meta key but different keys as a phrase in
    #     diff point ('modified')
    #   are identical to a phrase in diff point ('unmodified'), but
    #     does not yield them
    def head_to_diff_point
      if block_given?
        # iterate over all head phrases that have meta keys
        head_phrases.each do |head_phrase|
          idx = diff_point_phrases.find_index do |diff_point_phrase|
            diff_point_phrase['key'] == head_phrase['key']
          end

          state = compare_at(idx, head_phrase)
          old_phrase = idx ? diff_point_phrases[idx] : nil

          if state != :unmodified
            yield head_phrase, state, old_phrase
          end
        end
      else
        to_enum(__method__)
      end
    end

    def compare_at(idx, head_phrase)
      if idx
        if diff_point_phrases[idx]['string'] == head_phrase['string']
          :unmodified
        else
          :modified
        end
      else
        :added
      end
    end

    # identifies phrases in diff point that are not in head ('removed')
    def diff_point_to_head
      if block_given?
        diff_point_phrases.each do |diff_point_phrase|
          idx = head_phrases.find_index do |head_phrase|
            head_phrase['key'] == diff_point_phrase['key']
          end

          yield(diff_point_phrase, :removed) unless idx
        end
      else
        to_enum(__method__)
      end
    end
  end
end
