require 'rubygems/package'
require 'spec_helper'
require 'stringio'
require 'zlib'

include Txgh::Handlers

describe TgzStreamResponse do
  def read_tgz_from(io)
    contents = {}

    Zlib::GzipReader.wrap(io) do |gz|
      tar = Gem::Package::TarReader.new(gz)
      tar.each do |entry|
        contents[entry.full_name] = entry.read
      end
    end

    contents
  end

  let(:attachment) { 'abc123' }

  let(:enum) do
    {
      'first_file.yml' => "first\nfile\ncontents\n",
      'second_file.yml' => "wowowow\nanother file!\n"
    }
  end

  let(:response) do
    TgzStreamResponse.new(attachment, enum)
  end

  describe '#write_to' do
    it 'writes a gzipped tar file with the correct entries to the stream' do
      io = StringIO.new('', 'wb')
      response.write_to(io)
      io = io.reopen(io.string, 'rb')
      contents = read_tgz_from(io)
      expect(contents).to eq(enum)
    end
  end

  describe '#headers' do
    it 'includes the correct content type and disposition headers' do
      expect(response.headers).to eq({
        'Content-Disposition' => "attachment; filename=\"#{attachment}.tgz\"",
        'Content-Type' => 'application/x-gtar'
      })
    end
  end

  describe '#streaming?' do
    it 'returns true' do
      expect(response).to be_streaming
    end
  end
end
