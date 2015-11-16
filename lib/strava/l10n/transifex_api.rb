require 'faraday'
require 'faraday_middleware'
require 'json'

module Strava
  module L10n
    class TransifexApi

      API_ROOT = '/api/2'

      def initialize(connection)
        @connection = connection
      end

      def self.instance(username, password)
        connection = Faraday.new(url: 'https://www.transifex.com') do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.response :logger
          faraday.use FaradayMiddleware::FollowRedirects
          faraday.adapter Faraday.default_adapter
        end
        connection.basic_auth(username, password)
        connection.headers.update Accept: 'application/json'
        new connection
      end

      def update(tx_resource, content)
        content_io = StringIO::new content
        content_io.set_encoding Encoding::UTF_8.name
        content_part = Faraday::UploadIO.new(content_io,
            'application/octet-stream', tx_resource.source_file)
        slug = tx_resource.resource_slug
        payload = {
            content: content_part,
        }
        project = tx_resource.project_slug
        if resource_exists?(tx_resource)
          url = "#{API_ROOT}/project/#{project}/resource/#{slug}/content/"
          method = @connection.method :put
        else
          url = "#{API_ROOT}/project/#{project}/resources/"
          method = @connection.method :post
          payload[:slug] = slug
          payload[:name] = tx_resource.source_file
          payload[:i18n_type] = tx_resource.type
        end
        response = method.call url, payload
        if (response.status / 100) != 2
          raise "Failed Transifex API call - returned status code: #{response.status}, body: #{response.body}"
        end
        JSON.parse response.body
      end

      def resource_exists?(tx_resource)
        project = tx_resource.project_slug
        slug = tx_resource.resource_slug
        response = @connection.get "#{API_ROOT}/project/#{project}/resource/#{slug}/"
        response.status == 200
      end

      def download(tx_resource, lang)
        project_slug = tx_resource.project_slug
        resource_slug = tx_resource.resource_slug
        response = @connection.get "#{API_ROOT}/project/#{project_slug}/resource/#{resource_slug}/translation/#{lang}/"
        if (response.status / 100) != 2
          raise "Failed Transifex API call - returned status code: #{response.status}, body: #{response.body}"
        end
        json_data = JSON.parse response.body
        json_data['content']
      end

    end
  end
end

