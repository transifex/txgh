require 'ext/zipline/output_stream'

module Txgh
  module Handlers
    class ZipStreamResponse < StreamResponse

      def write_to(stream)
        Zipline::OutputStream.open(stream) do |zipfile|
          enum.each do |file_name, contents|
            zipfile.put_next_entry(file_name, contents.bytesize)
            zipfile << contents
          end
        end
      end

      def file_extension
        '.zip'
      end
    end
  end
end
