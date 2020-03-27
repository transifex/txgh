require 'base64'

module Txgh
  class GitApi
    class << self
      def create_from_client(client, repo_name)
        new(client, repo_name)
      end
    end

    attr_reader :client, :repo_name

    def initialize(client, repo_name)
      @client = client
      @repo_name = repo_name
    end
  end
end
