require 'spec_helper'
require 'tempfile'

include TxghServer

describe ZipStreamResponse do
  def read_zip_from(file)
    contents = {}

    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        contents[entry.name] = entry.get_input_stream.read
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
    ZipStreamResponse.new(attachment, enum)
  end

  describe '#write_to' do
    it 'writes a zip file with the correct entries to the stream' do
      # this does NOT WORK with a StringIO - zip contents MUST be written to a file
      io = Tempfile.new('testzip')
      response.write_to(io)
      contents = read_zip_from(io.path)
      expect(contents).to eq(enum)
      io.close
      io.unlink
    end
  end

  describe '#headers' do
    it 'includes the correct content type and disposition headers' do
      expect(response.headers).to eq({
        'Content-Disposition' => "attachment; filename=\"#{attachment}.zip\"",
        'Content-Type' => 'application/zip'
      })
    end
  end

  describe '#streaming?' do
    it 'returns true' do
      expect(response).to be_streaming
    end
  end
end
