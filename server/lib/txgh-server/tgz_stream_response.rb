require 'rubygems/package'
require 'stringio'
require 'zlib'

module TxghServer
  class TgzStreamResponse < StreamResponse
    PERMISSIONS = 0644

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

    def file_extension
      '.tgz'
    end

    private

    def flush(tar, pipe, gz)
      tar.flush
      gz.write(pipe.string)
      pipe.reopen('')
    end
  end
end
