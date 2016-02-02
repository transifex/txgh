require 'parseconfig'
require 'tempfile'

module Txgh
  # This class wraps the ParseConfig class from the parseconfig gem and
  # provides a way to load config from a string instead of just a file.
  class ParseConfig < ::ParseConfig
    class << self
      def load(contents)
        tmp = Tempfile.new('parseconfig')
        tmp.write(contents)
        tmp.flush
        load_file(tmp.path)
      ensure
        tmp.close if tmp
      end

      def load_file(path)
        # use the default file loading logic
        new(path)
      end
    end
  end
end
