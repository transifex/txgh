require 'faraday'
require 'faraday_middleware'
require 'json'
require 'set'

module Txgh
  class TransifexApi
    API_ROOT = '/api/2'

    class << self
      def create_from_credentials(username, password)
        connection = Faraday.new(url: 'https://www.transifex.com') do |faraday|
          faraday.request(:multipart)
          faraday.request(:json)
          faraday.request(:url_encoded)

          faraday.response(:logger)
          faraday.use(FaradayMiddleware::FollowRedirects)
          faraday.adapter(Faraday.default_adapter)
        end

        connection.basic_auth(username, password)
        connection.headers.update(Accept: 'application/json')
        create_from_connection(connection)
      end

      def create_from_connection(connection)
        new(connection)
      end
    end

    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def create_or_update(tx_resource, content, categories = [])
      if resource_exists?(tx_resource)
        resource = get_resource(*tx_resource.slugs)
        new_categories = Set.new(resource['categories'])
        new_categories.merge(categories)

        # update details first so new content is always tagged
        update_details(tx_resource, categories: new_categories.to_a)
        update_content(tx_resource, content)
      else
        create(tx_resource, content, categories)
      end
    end

    def create(tx_resource, content, categories = [])
      payload = {
        slug: tx_resource.resource_slug,
        name: tx_resource.source_file,
        i18n_type: tx_resource.type,
        categories: CategorySupport.join_categories(categories.uniq),
        content: get_content_io(tx_resource, content)
      }

      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resources/"
      response = connection.post(url, payload)
      raise_error!(response)
    end

    def delete(tx_resource)
      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resource/#{tx_resource.resource_slug}/"
      connection.delete(url)
    end

    def update_content(tx_resource, content)
      content_io = get_content_io(tx_resource, content)
      payload = { content: content_io }
      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resource/#{tx_resource.resource_slug}/content/"
      response = connection.put(url, payload)
      raise_error!(response)
    end

    def update_details(tx_resource, details = {})
      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resource/#{tx_resource.resource_slug}/"
      response = connection.put(url, details)
      raise_error!(response)
    end

    def resource_exists?(tx_resource)
      project = tx_resource.project_slug
      slug = tx_resource.resource_slug
      response = connection.get("#{API_ROOT}/project/#{project}/resource/#{slug}/")
      response.status == 200
    end

    def download(tx_resource, lang)
      project_slug = tx_resource.project_slug
      resource_slug = tx_resource.resource_slug
      response = connection.get(
        "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/translation/#{lang}/"
      )

      raise_error!(response)

      json_data = JSON.parse(response.body)
      json_data['content']
    end

    def get_resource(project_slug, resource_slug)
      url = "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/"
      response = connection.get(url)
      raise_error!(response)
      JSON.parse(response.body)
    end

    def get_resources(project_slug)
      url = "#{API_ROOT}/project/#{project_slug}/resources/"
      response = connection.get(url)
      raise_error!(response)
      JSON.parse(response.body)
    end

    def get_languages(project_slug)
      url = "#{API_ROOT}/project/#{project_slug}/languages/"
      response = connection.get(url)
      raise_error!(response)
      JSON.parse(response.body)
    end

    def get_project(project_slug)
      url = "#{API_ROOT}/project/#{project_slug}/"
      response = connection.get(url)
      raise_error!(response)
      JSON.parse(response.body)
    end

    def get_formats
      url = "#{API_ROOT}/formats/"
      response = connection.get(url)
      raise_error!(response)
      JSON.parse(response.body)
    end

    def get_stats(project_slug, resource_slug)
      url = "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/stats/"
      response = connection.get(url)
      raise_error!(response)
      JSON.parse(response.body)
    end

    private

    def get_content_io(tx_resource, content)
      content_io = StringIO::new(content)
      content_io.set_encoding(Encoding::UTF_8.name)
      Faraday::UploadIO.new(
        content_io, 'application/octet-stream', tx_resource.source_file
      )
    end

    def raise_error!(response)
      case response.status
        when 401
          raise TransifexUnauthorizedError
        when 404
          raise TransifexNotFoundError
        else
          if (response.status / 100) != 2
            raise TransifexApiError,
              "Failed Transifex API call - returned status code: #{response.status}, body: #{response.body}"
          end
      end
    end
  end
end

