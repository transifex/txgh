require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe TransifexApi do
  include StandardTxghSetup

  let(:connection) { double(:connection) }
  let(:api) { TransifexApi.create_from_connection(connection) }
  let(:resource) { tx_config.resources.first }
  let(:response) { double(:response) }

  describe '#create_or_update' do
    context 'with a preexisting resource' do
      before(:each) do
        expect(api).to receive(:resource_exists?).and_return(true)
      end

      it 'updates the resource with new content' do
        expect(api).to receive(:update_details).with(resource, categories: [])
        expect(api).to receive(:update_content).with(resource, 'new_content')
        expect(api).to receive(:get_resource).and_return({})

        api.create_or_update(resource, 'new_content')
      end

      it "additively updates the resource's categories" do
        expect(api).to receive(:update_details) do |rsrc, details|
          expect(details[:categories].sort).to eq(['branch:foobar', 'name:Jesse James'])
        end

        expect(api).to receive(:update_content).with(resource, 'new_content')
        expect(api).to receive(:get_resource).and_return({ 'categories' => ['name:Jesse James'] })

        api.create_or_update(resource, 'new_content', ['branch:foobar'])
      end

      it 'only submits a unique set of categories' do
        expect(api).to receive(:update_details).with(resource, categories: ['branch:foobar'])
        expect(api).to receive(:update_content).with(resource, 'new_content')
        expect(api).to receive(:get_resource).and_return({ 'categories' => ['branch:foobar'] })

        api.create_or_update(resource, 'new_content', ['branch:foobar'])
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
          expect(payload[:i18n_type]).to eq('YML')

          response
        end

        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return("{}")
        api.create_or_update(resource, 'new_content')
      end
    end
  end

  describe '#create' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:post) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/resources/")
        )

        expect(payload[:content].io.string).to eq('new_content')
        expect(payload[:categories]).to eq('abc def')
        response
      end

      allow(response).to receive(:status).and_return(200)
      api.create(resource, 'new_content', ['abc', 'def'])
    end

    it 'submits de-duped categories' do
      expect(connection).to receive(:post) do |url, payload|
        expect(payload[:categories]).to eq('abc')
        response
      end

      allow(response).to receive(:status).and_return(200)
      api.create(resource, 'new_content', ['abc', 'abc'])
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:post).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.create(resource, 'new_content') }.to raise_error(TransifexApiError)
    end
  end

  describe '#delete' do
    it 'deletes the given resource' do
      expect(connection).to receive(:delete) do |url|
        expect(url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )
      end

      api.delete(resource)
    end
  end

  describe '#update_content' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:put) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/content/")
        )

        expect(payload[:content].io.string).to eq('new_content')
        response
      end

      allow(response).to receive(:status).and_return(200)
      api.update_content(resource, 'new_content')
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:put).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.update_content(resource, 'new_content') }.to raise_error(TransifexApiError)
    end
  end

  describe '#update_details' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:put) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )

        expect(payload[:i18n_type]).to eq('FOO')
        expect(payload[:categories]).to eq(['abc'])
        response
      end

      allow(response).to receive(:status).and_return(200)
      api.update_details(resource, i18n_type: 'FOO', categories: ['abc'])
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:put).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.update_details(resource, {}) }.to raise_error(TransifexApiError)
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

      allow(response).to receive(:status).and_return(200)
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

      allow(response).to receive(:status).and_return(200)
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
      allow(response).to receive(:status).and_return(401)
      allow(response).to receive(:body).and_return('{}')
      expect { api.download(resource, language) }.to raise_error(TransifexApiError)
    end

    it 'raises a specific exception if the api responds with a 404 not found' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.download(resource, language) }.to raise_error(
        TransifexNotFoundError
      )
    end
  end

  describe '#get_resource' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )

        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"foo":"bar"}')
      expect(api.get_resource(*resource.slugs)).to eq({ 'foo' => 'bar' })
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.get_resource(*resource.slugs) }.to raise_error(TransifexApiError)
    end
  end

  describe '#get_resources' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/resources/")
        )

        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"foo":"bar"}')
      expect(api.get_resources(project_name)).to eq({ 'foo' => 'bar' })
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.get_resources(project_name) }.to raise_error(TransifexApiError)
    end
  end

  describe '#get_languages' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/languages/")
        )

        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('[{"language_code":"de"}]')
      expect(api.get_languages(project_name)).to eq([{ 'language_code' => 'de' }])
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.get_languages(project_name) }.to raise_error(TransifexApiError)
    end
  end

  describe '#get_project' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url, payload|
        expect(url).to(
          end_with("project/#{project_name}/")
        )

        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"slug":"projectslug"}')
      expect(api.get_project(project_name)).to eq({ 'slug' => 'projectslug' })
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.get_project(project_name) }.to raise_error(TransifexApiError)
    end
  end

  describe '#get_formats' do
    it 'makes a request with the correct parameters' do
      expect(connection).to receive(:get) do |url, payload|
        expect(url).to end_with("formats/")
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{}')
      expect(api.get_formats).to eq({})
    end

    it 'raises an exception if the api responds with an error code' do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:status).and_return(404)
      allow(response).to receive(:body).and_return('{}')
      expect { api.get_formats }.to raise_error(TransifexApiError)
    end
  end
end
