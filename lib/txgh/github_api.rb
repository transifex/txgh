require 'octokit'

module Txgh
  class GithubApi
    class << self
      def create_from_credentials(login, access_token)
        create_from_client(
          Octokit::Client.new(login: login, access_token: access_token)
        )
      end

      def create_from_client(client)
        new(client)
      end
    end

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def tree(repo, sha)
      client.tree(repo, sha, recursive: 1)
    end

    def blob(repo, sha)
      client.blob(repo, sha)
    end

    def create_ref(repo, branch, sha)
      client.create_ref(repo, branch, sha) rescue false
    end

    def commit(repo, branch, path, content)
      blob = client.create_blob(repo, content)
      master = client.ref(repo, branch)
      base_commit = get_commit(repo, master[:object][:sha])

      tree_data = [{ path: path, mode: '100644', type: 'blob', sha: blob }]
      tree_options = { base_tree: base_commit[:commit][:tree][:sha] }

      tree = client.create_tree(repo, tree_data, tree_options)
      commit = client.create_commit(
        repo, "Updating translations for #{path}", tree[:sha], master[:object][:sha]
      )

      client.update_ref(repo, branch, commit[:sha])
    end

    def get_commit(repo, sha)
      client.commit(repo, sha)
    end

    def download(path, branch)
      master = client.ref(git_repo, branch)
      commit = client.commit(git_repo, master[:object][:sha])
      tree = client.tree(git_repo, commit[:commit][:tree][:sha])

      if found = tree[:tree].find { |t| t[:path] == path }
        blob(git_repo, found[:sha])
      end
    end

  end
end
