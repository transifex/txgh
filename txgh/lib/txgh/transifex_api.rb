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
      name = if tx_resource.branch
        "#{tx_resource.source_file} (#{tx_resource.branch})"
      else
        tx_resource.source_file
      end

      payload = {
        slug: tx_resource.resource_slug,
        name: name,
        i18n_type: tx_resource.type,
        categories: CategorySupport.join_categories(categories.uniq),
        content: get_content_io(tx_resource, content)
      }

      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resources/"
      post(url, payload)
    end

    def delete_resource(tx_resource)
      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resource/#{tx_resource.resource_slug}/"
      delete(url)
    end

    def update_content(tx_resource, content)
      content_io = get_content_io(tx_resource, content)
      payload = { content: content_io }
      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resource/#{tx_resource.resource_slug}/content/"
      put(url, payload)
    end

    def update_details(tx_resource, details = {})
      url = "#{API_ROOT}/project/#{tx_resource.project_slug}/resource/#{tx_resource.resource_slug}/"
      put(url, details)
    end

    def resource_exists?(tx_resource)
      project = tx_resource.project_slug
      slug = tx_resource.resource_slug
      response = get("#{API_ROOT}/project/#{project}/resource/#{slug}/")
      response.status == 200
    rescue TransifexNotFoundError
      false
    end

    def download(*args)
      project_slug, resource_slug = case args.first
        when TxResource, TxBranchResource
          [args.first.project_slug, args.first.resource_slug]
        else
          [args[0], args[1]]
      end

      lang = args.last

      json_data = get_json(
        "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/translation/#{lang}/"
      )

      json_data['content']
    end

    def get_resource(project_slug, resource_slug)
      url = "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/"
      get_json(url)
    end

    def get_resources(project_slug)
      url = "#{API_ROOT}/project/#{project_slug}/resources/"
      get_json(url)
    end

    def get_languages(project_slug)
      url = "#{API_ROOT}/project/#{project_slug}/languages/"
      get_json(url)
    end

    def get_project(project_slug)
      url = "#{API_ROOT}/project/#{project_slug}/"
      get_json(url)
    end

    def get_formats
      url = "#{API_ROOT}/formats/"
      get_json(url)
    end

    def get_stats(project_slug, resource_slug)
      url = "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/stats/"
      get_json(url)
    end

    private

    def get(url)
      act(:get, url)
    end

    def post(url, body)
      act(:post, url, body)
    end

    def put(url, body)
      act(:put, url, body)
    end

    def delete(url)
      act(:delete, url)
    end

    def get_json(url)
      response = get(url)
      JSON.parse(response.body)
    end

    def act(verb, url, body = nil)
      response = connection.send(verb, url, body)
      raise_error!(response)
      response
    end

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
          raise TransifexUnauthorizedError, "401 Unauthorized: #{response.env.url}"
        when 404
          raise TransifexNotFoundError, "404 Not Found: #{response.env.url}"
        else
          if (response.status / 100) != 2
            raise TransifexApiError.new(
              "HTTP #{response.status}: #{response.env.url}, body: #{response.body}",
              response.status
            )
          end
      end
    end
  end
end
