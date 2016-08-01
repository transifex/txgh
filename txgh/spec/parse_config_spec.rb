require 'spec_helper'
require 'tempfile'

include Txgh

describe Txgh::ParseConfig do
  let(:contents) do
    """
    [header]
    key = val

    [header2]
    key2 = val2
    """
  end

  shared_examples 'a correct config loader' do
    it 'has correctly parsed the given config' do
      expect(config).to be_a(::ParseConfig)
      expect(config.groups).to eq(%w(header header2))
      expect(config.params).to eq(
        'header' => { 'key' => 'val' },
        'header2' => { 'key2' => 'val2' }
      )
    end
  end

  describe '.load' do
    let(:config) do
      Txgh::ParseConfig.load(contents)
    end

    it_behaves_like 'a correct config loader'
  end

  describe '.load_file' do
    around(:each) do |example|
      Tempfile.open('parseconfig-test') do |f|
        f.write(contents)
        f.flush
        @file = f
        example.run
      end
    end

    let(:config) do
      Txgh::ParseConfig.load_file(@file.path)
    end

    it_behaves_like 'a correct config loader'
  end
end
