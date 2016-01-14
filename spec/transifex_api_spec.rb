require 'spec_helper'

include Txgh

describe TransifexApi do
  include StandardTxghSetup

  let(:connection) { double(:connection) }
  let(:api) { TransifexApi.create_from_connection(connection) }
  let(:resource) { transifex_project.resources.first }
  let(:response) { double(:response) }

  describe '#update' do
    context 'with a preexisting resource' do
      before(:each) do
        expect(api).to receive(:resource_exists?).and_return(true)
      end

      it 'makes a request with the correct parameters' do
        expect(connection).to receive(:put) do |url, payload|
          expect(url).to(
            end_with("project/#{project_name}/resource/#{resource_slug}/content/")
          )

          response
        end

        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return('{}')
        api.update(resource, 'new_content')
      end

      it 'returns the response body on a successful request' do
        allow(connection).to receive(:put).and_return(response)
        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return('{"foo": "bar"}')
        expect(api.update(resource, 'new content')).to eq('foo' => 'bar')
      end

      it 'raises an error on an unsuccessful request' do
        allow(connection).to receive(:put).and_return(response)
        allow(response).to receive(:status).and_return(404)
        allow(response).to receive(:body).and_return('{}')
        expect { api.update(resource, 'new content') }.to raise_error(TransifexApiError)
      end
    end

    context 'with a non-existent resource' do
      before(:each) do
        expect(api).to receive(:resource_exists?).and_return(false)
      end

      it 'makes a request with the correct parameters' do
        expect(connection).to receive(:post) do |url, payload|
          expect(url).to(
            end_with("project/#{project_name}/resources/")
          )

          expect(payload[:slug]).to eq(resource_slug)
          expect(payload[:name]).to eq(resource.source_file)
          expect(payload[:i18n_type]).to eq('PO')

          response
        end

        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return("{}")
        api.update(resource, 'new_content')
      end

      it 'returns the response body on a successful request' do
        allow(connection).to receive(:post).and_return(response)
        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return('{"foo": "bar"}')
        expect(api.update(resource, 'new content')).to eq('foo' => 'bar')
      end

      it 'raises an error on an unsuccessful request' do
        allow(connection).to receive(:post).and_return(response)
        allow(response).to receive(:status).and_return(404)
        allow(response).to receive(:body).and_return('{}')
        expect { api.update(resource, 'new content') }.to raise_error(TransifexApiError)
      end
    end
  end

  describe '#resource_exists?' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url|
        expect(url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )

        response
      end

      expect(response).to receive(:status).and_return(200)
      api.resource_exists?(resource)
    end

    it 'returns true if the api responds with a 200 status code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(200)
      expect(api.resource_exists?(resource)).to eq(true)
    end

    it 'returns false if the api does not respond with a 200 status code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      expect(api.resource_exists?(resource)).to eq(false)
    end
  end

  describe '#download' do
    let(:language) { 'pt-BR' }

    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url|
        expect(url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/translation/#{language}/")
        )

        response
      end

      expect(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{}')
      api.download(resource, language)
    end

    it 'parses and returns the response content' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"content": "foobar"}')
      expect(api.download(resource, language)).to eq('foobar')
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.download(resource, language) }.to raise_error(TransifexApiError)
    end
  end
end
