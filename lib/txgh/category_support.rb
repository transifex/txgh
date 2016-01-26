module Txgh
  module CategorySupport
    def deserialize_categories(categories_arr)
      categories_arr.each_with_object({}) do |category, ret|
        if idx = category.index(':')
          ret[category[0...idx]] = category[(idx + 1)..-1]
        end
      end
    end

    def serialize_categories(categories_hash)
      categories_hash.map do |key, value|
        "#{key}:#{value}"
      end
    end

    def escape_category(str)
      str.gsub(' ', '_')
    end

    def join_categories(arr)
      arr.join(' ')
    end
  end

  # add all the methods as class methods (they're also available as instance
  # methods for anyone who includes this module)
  CategorySupport.extend(CategorySupport)
end
