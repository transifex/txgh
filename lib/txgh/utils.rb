module Txgh
  module Utils
    def slugify(str)
      str.gsub('/', '_')
    end

    def absolute_branch(branch)
      if branch.include?('tags/')
        branch
      elsif branch.include?('heads/')
        branch
      else
        "heads/#{branch}"
      end
    end
  end

  Utils.extend(Utils)
end
