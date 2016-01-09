require 'octokit'

module Txgh
  class GitHubApi
    attr_reader :client

    def initialize(login, oauth_token)
      @client = Octokit::Client.new(login: login, access_token: oauth_token)
    end

    def tags(repo)
      client.tags(repo)
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
      base_commit = client.commit(repo, master[:object][:sha])

      tree_data = [{ path: path, mode: '100644', type: 'blob', sha: blob }]
      tree_options = { base_tree: base_commit[:commit][:tree][:sha] }

      tree = client.create_tree(repo, tree_data, tree_options)
      commit = client.create_commit(
        repo, "Updating translations for #{path} [skip ci]", tree[:sha], master[:object][:sha]
      )

      client.update_ref(repo, branch, commit[:sha])
    end

    def get_commit(repo, sha)
      client.commit(repo, sha)
    end

  end
end
