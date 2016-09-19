require 'spec_helper'
require 'helpers/nil_logger'

include TxghServer
include TxghServer::Webhooks::Github

describe PingHandler do
  let(:handler) do
    PingHandler.new(NilLogger.new)
  end

  it 'responds with a 200 success' do
    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq({})
  end
end
