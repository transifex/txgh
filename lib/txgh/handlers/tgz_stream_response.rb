require 'mime/types'
require 'rubygems/package'
require 'stringio'
require 'zlib'

module Txgh
  module Handlers
    class TgzStreamResponse
      PERMISSIONS = 0644

      attr_reader :attachment, :enum

      def initialize(attachment, enum)
        @attachment = attachment
        @enum = enum
      end

      def write_to(stream)
        Zlib::GzipWriter.wrap(stream) do |gz|
          pipe = StringIO.new('', 'wb')
          tar = Gem::Package::TarWriter.new(pipe)

          enum.each do |file_name, contents|
            tar.add_file(file_name, PERMISSIONS) do |f|
              f.write(contents)
            end

            flush(tar, pipe, gz)
            stream.flush
          end

          flush(tar, pipe, gz)
        end
      end

      def streaming?
        true
      end

      def headers
        @headers ||= {
          'Content-Disposition' => "attachment; filename=\"#{attachment}.tgz\"",
          'Content-Type' => MIME::Types.type_for('.tgz').first.content_type
        }
      end

      private

      def flush(tar, pipe, gz)
        tar.flush
        gz.write(pipe.string)
        pipe.reopen('')
      end
    end
  end
end
