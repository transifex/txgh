require 'mime/types'
require 'zipline'

module Txgh
  module Handlers
    class ZipStreamResponse
      attr_reader :attachment, :enum

      def initialize(attachment, enum)
        @attachment = attachment
        @enum = enum
      end

      def write_to(stream)
        Zipline::OutputStream.open(stream) do |zipfile|
          enum.each do |file_name, contents|
            zipfile.put_next_entry(file_name, contents.bytesize)
            zipfile << contents
          end
        end
      end

      def headers
        @headers ||= {
          'Content-Disposition' => "attachment; filename=\"#{attachment}.zip\"",
          'Content-Type' => MIME::Types.type_for('.zip').first.content_type
        }
      end

      def streaming?
        true
      end
    end
  end
end
