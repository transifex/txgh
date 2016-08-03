require 'spec_helper'

include TxghServer
include TxghServer::Webhooks::Github

describe PingHandler do
  let(:handler) do
    PingHandler.new
  end

  it 'responds with a 200 success' do
    response = handler.execute
    expect(response.status).to eq(200)
    expect(response.body).to eq({})
  end
end
