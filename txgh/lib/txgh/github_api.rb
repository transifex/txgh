require 'base64'
require 'octokit'

module Txgh
  class GithubApi
    class << self
      def create_from_credentials(login, access_token, repo_name)
        create_from_client(
          Octokit::Client.new(login: login, access_token: access_token), repo_name
        )
      end

      def create_from_client(client, repo_name)
        new(client, repo_name)
      end
    end

    attr_reader :client, :repo_name

    def initialize(client, repo_name)
      @client = client
      @repo_name = repo_name
    end

    def tree(sha)
      client.tree(repo_name, sha, recursive: 1)
    end

    def blob(sha)
      client.blob(repo_name, sha)
    end

    def create_ref(branch, sha)
      client.create_ref(repo_name, branch, sha) rescue false
    end

    def update_contents(branch, content_list, message)
      content_list.each do |file_params|
        path = file_params.fetch(:path)
        new_contents = file_params.fetch(:contents)
        branch = Utils.relative_branch(branch)

        file_sha = file_params.fetch(:sha) do
          begin
            client.contents(repo_name, { path: path, ref: branch })[:sha]
          rescue Octokit::NotFound
            nil
          end
        end

        # If the file doesnt exist, then it isn't tracked by git and file_sha
        # will be nil. In git land, a SHA of all zeroes means create a new file
        # instead of updating an existing one.
        current_sha = file_sha || '0' * 40
        new_sha = Utils.git_hash_blob(new_contents)
        options = { branch: branch }

        if current_sha != new_sha
          client.update_contents(
            repo_name, path, message, current_sha, new_contents, options
          )
        end
      end
    end

    def get_commit(sha)
      client.commit(repo_name, sha)
    end

    def get_ref(ref)
      client.ref(repo_name, ref)
    end

    def download(path, branch)
      file = client.contents(repo_name, { path: path, ref: branch }).to_h

      file[:content] = case file[:encoding]
        when 'base64'
          Base64.decode64(file[:content])
        else
          file[:content].force_encoding(file[:encoding])
      end

      file.delete(:encoding)
      file
    end

    def create_status(sha, state, options = {})
      client.create_status(repo_name, sha, state, options)
    end
  end
end
