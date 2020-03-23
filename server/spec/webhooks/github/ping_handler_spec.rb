require 'spec_helper'
require 'helpers/nil_logger'

describe TxghServer::Webhooks::Github::PingHandler do
  let(:handler) do
    TxghServer::Webhooks::Github::PingHandler.new(NilLogger.new)
  end

  it 'responds with a 200 success' do
    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq({})
  end
end
