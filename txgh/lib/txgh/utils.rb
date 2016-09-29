require 'digest'

module Txgh
  module Utils
    def slugify(text)
      text
        .gsub('/', '_')
        .gsub(/[^\w\s_-]/, '')
        .gsub(/[-\s]+/, '-')
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

    def relative_branch(branch)
      branch.strip.sub(/\A(heads|tags)\//, '')
    end

    def branches_equal?(first, second)
      absolute_branch(first) == absolute_branch(second)
    end

    def is_tag?(ref)
      ref.include?('tags/')
    end

    def git_hash_blob(str)
      Digest::SHA1.hexdigest("blob #{str.bytesize}\0#{str}")
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

    def booleanize(obj)
      case obj
        when String
          obj.downcase == 'true'
        when TrueClass, FalseClass
          obj
      end
    end

    def deep_symbolize_keys(obj)
      case obj
        when Hash
          obj.each_with_object({}) do |(k, v), ret|
            ret[k.to_sym] = deep_symbolize_keys(v)
          end

        when Array
          obj.map do |elem|
            deep_symbolize_keys(elem)
          end

        else
          obj
      end
    end
  end

  Utils.extend(Utils)
end
