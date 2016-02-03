module Txgh
  module Utils
    def slugify(str)
      str.gsub('/', '_')
    end
  end

  Utils.extend(Utils)
end
