module Txgh
  class DiffCalculator
    class << self
      def compare(head_phrases, diff_point_phrases)
        new(head_phrases, diff_point_phrases).compare
      end
    end

    INCLUDED_STATES = [:added, :modified]

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
      INCLUDED_STATES.each_with_object({}) do |state, ret|
        ret[state] = diff1[state] + diff2[state]
      end
    end

    def compare_head
      compare_enum(head_to_diff_point)
    end

    def compare_diff_point
      compare_enum(diff_point_to_head)
    end

    def compare_enum(enum)
      enum.each_with_object(new_hash_of_arrays) do |(phrase, state), diff|
        diff[state] << phrase
      end
    end

    # identifies phrases in head that:
    #   are not in diff point ('added')
    #   have the same key but different strings diff point ('modified')
    #   are identical to a phrase in diff point ('unmodified'), but
    #     does not yield them
    def head_to_diff_point
      return to_enum(__method__) unless block_given?

      # iterate over all head phrases that have keys
      head_phrases.each do |head_phrase|
        idx = diff_point_phrases.find_index do |diff_point_phrase|
          diff_point_phrase['key'] == head_phrase['key']
        end

        state = compare_at(idx, head_phrase)
        yield(head_phrase, state) if INCLUDED_STATES.include?(state)
      end
    end

    def compare_at(idx, head_phrase)
      return :added unless idx

      if diff_point_phrases[idx]['string'] == head_phrase['string']
        :unmodified
      else
        :modified
      end
    end

    # identifies phrases in diff point that are not in head ('removed')
    def diff_point_to_head
      return to_enum(__method__) unless block_given?

      diff_point_phrases.each do |diff_point_phrase|
        idx = head_phrases.find_index do |head_phrase|
          head_phrase['key'] == diff_point_phrase['key']
        end

        yield(diff_point_phrase, :removed) unless idx
      end
    end

    def new_hash_of_arrays
      Hash.new { |hash, key| hash[key] = [] }
    end
  end
end
