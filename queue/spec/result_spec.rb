require 'spec_helper'

include TxghQueue

describe Result do
  context 'with a response' do
    let(:response) { TxghServer::Response.new(200, 'Ok') }
    let(:result) { Result.new(Status.ok, response) }

    describe 'has_response?' do
      it 'does have a response' do
        expect(result.has_response?).to eq(true)
      end
    end

    describe 'has_error?' do
      it 'does not have an error' do
        expect(result.has_error?).to eq(false)
      end
    end

    describe '#response' do
      it 'returns the response' do
        expect(result.response).to eq(response)
      end
    end

    describe '#error' do
      it 'returns nil' do
        expect(result.error).to eq(nil)
      end
    end
  end

  context 'with an error' do
    let(:error) { StandardError.new }
    let(:result) { Result.new(Status.fail, error) }

    describe 'has_response?' do
      it 'does not have a response' do
        expect(result.has_response?).to eq(false)
      end
    end

    describe 'has_error?' do
      it 'does have an error' do
        expect(result.has_error?).to eq(true)
      end
    end

    describe '#response' do
      it 'returns nil' do
        expect(result.response).to eq(nil)
      end
    end

    describe '#error' do
      it 'returns nil' do
        expect(result.error).to eq(error)
      end
    end
  end
end
