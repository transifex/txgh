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
  end

  Utils.extend(Utils)
end
