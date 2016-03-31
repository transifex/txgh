module Txgh
  module Utils
    def slugify(str)
      str.gsub('/', '_')
    end

    def absolute_branch(branch)
      return unless branch
      if is_tag?(branch)
        branch
      elsif branch.include?('heads/')
        branch
      else
        "heads/#{branch}"
      end
    end

    def is_tag?(ref)
      ref.include?('tags/')
    end

    # Builds a hash from an array of hashes using a common key present in all
    # the elements. For example, consider this array of hashes:
    #
    # arr = [
    #   { 'param1' => 'dogs', 'param2' => 'hairy' },
    #   { 'param1' => 'cats', 'param2' => 'fuzzy' }
    # ]
    #
    # calling index_on('param1', arr) returns:
    #
    # {
    #   'dogs' => { 'param1' => 'dogs', 'param2' => 'hairy' },
    #   'cats' => { 'param1' => 'cats', 'param2' => 'fuzzy' }
    # }
    def index_on(key, arr)
      arr.each_with_object({}) do |hash, ret|
        ret[hash[key]] = hash
      end
    end
  end

  Utils.extend(Utils)
end
