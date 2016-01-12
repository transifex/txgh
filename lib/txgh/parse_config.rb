require 'parseconfig'
require 'tempfile'

module Txgh
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
        new(path)
      end
    end
  end
end
