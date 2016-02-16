require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe TxConfig do
  include StandardTxghSetup

  describe '.load' do
    it 'parses the config correctly' do
      config_str = """
        [main]
        host = https://www.transifex.com
        lang_map = pt-BR:pt, ko-KR:ko

        [my_proj.my_resource]
        file_filter = translations/<lang>/sample.po
        source_file = sample.po
        source_lang = en
        type = PO
      """

      config = TxConfig.load(config_str)
      expect(config.lang_map).to eq('pt-BR' => 'pt', 'ko-KR' => 'ko')
      expect(config.resources.size).to eq(1)

      resource = config.resources.first
      expect(resource.project_slug).to eq('my_proj')
      expect(resource.resource_slug).to eq('my_resource')
      expect(resource.source_file).to eq('sample.po')
      expect(resource.source_lang).to eq('en')
      expect(resource.translation_file).to eq('translations/<lang>/sample.po')
      expect(resource.type).to eq('PO')
    end
  end

  describe '#resource' do
    it 'finds the resource by slug' do
      resource = tx_config.resource(resource_slug)
      expect(resource).to be_a(TxResource)
      expect(resource.resource_slug).to eq(resource_slug)
    end

    it 'returns nil if there is no resource with the given slug' do
      resource = tx_config.resource('foobarbaz')
      expect(resource).to be_nil
    end
  end
end
