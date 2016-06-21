require 'spec_helper'
require 'helpers/nil_logger'

include Txgh
include Txgh::Handlers

describe TransifexProjectHookHandler do
  include StandardTxghSetup

  let(:new_config) do
    <<-TX_CONFIG
    [main]
    host = https://www.transifex.com
    lang_map =

    [common]
    file_filter = config/locales/<lang>.yml
    source_lang = en
    source_file = en.yml
    type = YML
    minimum_perc = 20

    [extra]
    file_filter = config/locales/extra/<lang>.yml
    source_lang = en
    source_file = en.yml
    type = YML
    minimum_perc = 20
    TX_CONFIG
  end

  let!(:handler) do
    TransifexProjectHookHandler.new(
      project: transifex_project,
      new_config: new_config,
      logger: logger
    )
  end

  it 'updates project configuration' do
    parse_config = double
    expect(Txgh::ParseConfig).to receive(:load).with(new_config).and_return(parse_config)
    expect(parse_config).to receive(:write)

    handler.execute
  end
end
