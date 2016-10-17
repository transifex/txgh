require 'spec_helper'

include TxghQueue

describe ErrorHandlers::ServerResponse do
  describe '.can_handle?' do
    it 'can reply to TxghServer responses' do
      server_response = TxghServer::Response.new(200, 'Ok')
      expect(described_class.can_handle?(server_response)).to eq(true)
    end

    it "can't reply to anything else" do
      expect(described_class.can_handle?('foo')).to eq(false)
    end
  end

  describe '.status_for' do
    it 'replies with ok if the status code is in the 200 range' do
      server_response = TxghServer::Response.new(201, 'Created')
      reply = described_class.status_for(server_response)
      expect(reply).to eq(Status.ok)
    end

    it 'replies with ok if the status code is in the 300 range' do
      server_response = TxghServer::Response.new(304, 'Not modified')
      reply = described_class.status_for(server_response)
      expect(reply).to eq(Status.ok)
    end

    it 'replies with fail if the status code is in the 400 range' do
      server_response = TxghServer::Response.new(404, 'Not found')
      reply = described_class.status_for(server_response)
      expect(reply).to eq(Status.fail)
    end

    it 'replies with fail if the status code is in the 500 range' do
      server_response = TxghServer::Response.new(502, 'Bad gateway')
      reply = described_class.status_for(server_response)
      expect(reply).to eq(Status.fail)
    end
  end
end
