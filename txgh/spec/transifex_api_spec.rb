require 'spec_helper'
require 'helpers/standard_txgh_setup'

describe Txgh::TransifexApi do
  FakeEnv = Struct.new(:url)
  FakeRequest = Struct.new(:body)
  FakeResponse = Struct.new(:env, :status, :body)

  class FakeConnection
    %w(get post put delete).each do |verb|
      define_method(:"on_#{verb}") do |&block|
        callbacks[verb] = block
      end

      define_method(verb) do |url, body = nil|
        env = FakeEnv.new(url)
        request = FakeRequest.new(body)
        response = FakeResponse.new(env)
        callbacks[verb].call(request, response)
        response
      end
    end

    private

    def callbacks
      @callbacks ||= {}
    end
  end

  include StandardTxghSetup

  let(:connection) { FakeConnection.new }
  let(:api) { described_class.create_from_connection(connection) }
  let(:resource) { tx_config.resource(resource_slug) }

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
        expect(connection).to receive(:post).and_call_original
      end

      it 'makes a request with the correct parameters' do
        connection.on_post do |request, response|
          response.status = 200
          response.body = '{}'

          expect(response.env.url).to(
            end_with("project/#{project_name}/resources/")
          )

          expect(request.body[:slug]).to eq(resource_slug)
          expect(request.body[:name]).to eq(resource.source_file)
          expect(request.body[:i18n_type]).to eq('YML')
        end

        api.create_or_update(resource, 'new_content')
      end
    end
  end

  describe '#create' do
    before(:each) do
      expect(connection).to receive(:post).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_post do |request, response|
        response.status = 200

        expect(response.env.url).to(
          end_with("project/#{project_name}/resources/")
        )

        expect(request.body[:name]).to eq('sample.yml')
        expect(request.body[:content].io.string).to eq('new_content')
        expect(request.body[:categories]).to eq('abc def')
      end

      api.create(resource, 'new_content', ['abc', 'def'])
    end

    it 'submits de-duped categories' do
      connection.on_post do |request, response|
        response.status = 200
        expect(request.body[:categories]).to eq('abc')
      end

      api.create(resource, 'new_content', ['abc', 'abc'])
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_post do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.create(resource, 'new_content') }.to(
        raise_error(TransifexNotFoundError) do |e|
          expect(e.status_code).to eq(404)
        end
      )
    end

    context 'with a branch-based resource' do
      let(:resource) { tx_config.resource(resource_slug, ref) }

      it "includes the branch in the resource's name" do
        connection.on_post do |request, response|
          response.status = 200
          expect(request.body[:name]).to eq('sample.yml (heads/master)')
        end

        api.create(resource, 'new_content')
      end
    end
  end

  describe '#delete_resource' do
    before(:each) do
      expect(connection).to receive(:delete).and_call_original
    end

    it 'deletes the given resource' do
      connection.on_delete do |_, response|
        response.status = 200

        expect(response.env.url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )
      end

      api.delete_resource(resource)
    end
  end

  describe '#update_content' do
    before(:each) do
      expect(connection).to receive(:put).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_put do |request, response|
        response.status = 200

        expect(response.env.url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/content/")
        )

        expect(request.body[:content].io.string).to eq('new_content')
      end

      api.update_content(resource, 'new_content')
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_put do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.update_content(resource, 'new_content') }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe '#update_details' do
    before(:each) do
      expect(connection).to receive(:put).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_put do |request, response|
        response.status = 200

        expect(response.env.url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )

        expect(request.body[:i18n_type]).to eq('FOO')
        expect(request.body[:categories]).to eq(['abc'])
      end

      api.update_details(resource, i18n_type: 'FOO', categories: ['abc'])
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_put do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.update_details(resource, {}) }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe '#resource_exists?' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200

        expect(response.env.url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )
      end

      api.resource_exists?(resource)
    end

    it 'returns true if the api responds with a 200 status code' do
      connection.on_get { |_, response| response.status = 200 }
      expect(api.resource_exists?(resource)).to eq(true)
    end

    it 'returns false if the api does not respond with a 200 status code' do
      connection.on_get { |_, response| response.status = 404 }
      expect(api.resource_exists?(resource)).to eq(false)
    end
  end

  describe '#download' do
    let(:language) { 'pt-BR' }

    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '{"content": "foobar"}'

        expect(response.env.url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/translation/#{language}/")
        )
      end

      expect(api.download(resource, language)).to eq('foobar')
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 401
        response.body = '{}'
      end

      expect { api.download(resource, language) }.to(
        raise_error(TransifexUnauthorizedError) do |e|
          expect(e.status_code).to eq(401)
        end
      )
    end

    it 'raises a specific exception if the api responds with a 404 not found' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.download(resource, language) }.to raise_error(
        TransifexNotFoundError
      )
    end
  end

  describe '#get_resource' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '{"foo":"bar"}'

        expect(response.env.url).to(
          end_with("project/#{project_name}/resource/#{resource_slug}/")
        )
      end

      expect(api.get_resource(*resource.slugs)).to eq({ 'foo' => 'bar' })
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_resource(*resource.slugs) }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe '#get_resources' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '{"foo":"bar"}'

        expect(response.env.url).to(
          end_with("project/#{project_name}/resources/")
        )
      end

      expect(api.get_resources(project_name)).to eq({ 'foo' => 'bar' })
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_resources(project_name) }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe '#get_languages' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '[{"language_code":"de"}]'

        expect(response.env.url).to(
          end_with("project/#{project_name}/languages/")
        )
      end

      expect(api.get_languages(project_name)).to eq([{ 'language_code' => 'de' }])
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_languages(project_name) }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe '#get_project' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '{"slug":"projectslug"}'

        expect(response.env.url).to(
          end_with("project/#{project_name}/")
        )
      end

      expect(api.get_project(project_name)).to eq({ 'slug' => 'projectslug' })
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_project(project_name) }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe '#get_formats' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '{}'

        expect(response.env.url).to(
          end_with('formats/')
        )
      end

      expect(api.get_formats).to eq({})
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_formats }.to raise_error(TransifexApiError)
    end
  end

  describe '#get_stats' do
    before(:each) do
      expect(connection).to receive(:get).and_call_original
    end

    it 'makes a request with the correct parameters' do
      connection.on_get do |_, response|
        response.status = 200
        response.body = '{}'

        expect(response.env.url).to(
          end_with('stats/')
        )
      end

      expect(api.get_stats(project_name, resource_slug)).to eq({})
    end

    it 'raises an exception if the api responds with an error code' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_stats(project_name, resource_slug) }.to(
        raise_error(TransifexApiError)
      )
    end
  end

  describe 'errors' do
    it 'includes the URL in the error message on 401' do
      connection.on_get do |_, response|
        response.status = 401
        response.body = '{}'
      end

      expect { api.get_formats }.to raise_error do |error|
        expect(error).to be_a(TransifexUnauthorizedError)
        expect(error.message).to eq('401 Unauthorized: /api/2/formats/')
      end
    end

    it 'includes the URL in the error message on 404' do
      connection.on_get do |_, response|
        response.status = 404
        response.body = '{}'
      end

      expect { api.get_formats }.to raise_error do |error|
        expect(error).to be_a(TransifexNotFoundError)
        expect(error.message).to eq('404 Not Found: /api/2/formats/')
      end
    end

    it 'includes the URL in the error message on unexpected error' do
      connection.on_get do |_, response|
        response.status = 422
        response.body = '{}'
      end

      expect { api.get_formats }.to raise_error do |error|
        expect(error).to be_a(TransifexApiError)
        expect(error.message).to eq('HTTP 422: /api/2/formats/, body: {}')
      end
    end
  end
end
