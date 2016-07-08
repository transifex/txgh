require 'base64'
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

    def update_contents(repo, branch, content_map, message)
      content_map.each do |path, new_contents|
        branch = Utils.relative_branch(branch)
        file = client.contents(repo, { path: path, ref: branch})
        current_contents = Base64.decode64(file[:content])
        current_sha = file[:sha]

        new_sha = Utils.git_hash_blob(new_contents)
        options = { branch: branch }

        if current_sha != new_sha
          client.update_contents(
            repo, path, message, current_sha, new_contents, options
          )
        end
      end
    end

    def commit(repo, branch, content_map, message, allow_empty = false)
      parent = client.ref(repo, branch)
      base_commit = get_commit(repo, parent[:object][:sha])

      tree_data = content_map.map do |path, content|
        blob = client.create_blob(repo, content)
        { path: path, mode: '100644', type: 'blob', sha: blob }
      end

      tree_options = { base_tree: base_commit[:commit][:tree][:sha] }

      tree = client.create_tree(repo, tree_data, tree_options)
      commit = client.create_commit(
        repo, message, tree[:sha], parent[:object][:sha]
      )

      # don't update the ref if the commit introduced no new changes
      unless allow_empty
        diff = client.compare(repo, parent[:object][:sha], commit[:sha])
        return if diff[:files].empty?
      end

      # false means don't force push
      client.update_ref(repo, branch, commit[:sha], false)
    end

    def get_commit(repo, sha)
      client.commit(repo, sha)
    end

    def get_ref(repo, ref)
      client.ref(repo, ref)
    end

    def download(repo, path, branch)
      master = client.ref(repo, branch)
      commit = client.commit(repo, master[:object][:sha])
      tree = client.tree(repo, commit[:commit][:tree][:sha], recursive: 1)

      if found = tree[:tree].find { |t| t[:path] == path }
        b = blob(repo, found[:sha])
        b['encoding'] == 'utf-8' ? b['content'] : Base64.decode64(b['content'])
      end
    end

    def create_status(repo, sha, state, options = {})
      client.create_status(repo, sha, state, options)
    end

  end
end
