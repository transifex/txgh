require 'gitlab'

module Txgh
  class GitlabApi < GitApi
    class << self
      def create_from_credentials(_login, access_token, repo_name)
        Gitlab.endpoint = 'https://gitlab.com/api/v4'
        create_from_client(
          Gitlab.client(private_token: access_token),
          repo_name
        )
      end
    end

    def update_contents(branch, content_list, message)
      content_list.each do |file_params|
        path = file_params.fetch(:path)
        new_contents = file_params.fetch(:contents)
        branch = Utils.relative_branch(branch)

        file_sha = file_params.fetch(:sha) do
          begin
            client.get_file(repo_name, path, branch).blob_id
          rescue ::Gitlab::Error::NotFound
            nil
          end
        end

        # If the file doesnt exist, then it isn't tracked by git and file_sha
        # will be nil. In git land, a SHA of all zeroes means create a new file
        # instead of updating an existing one.
        current_sha = file_sha || '0' * 40
        new_sha = Utils.git_hash_blob(new_contents)

        if current_sha != new_sha
          client.edit_file(repo_name, path, branch, new_contents, message)
        end
      end
    end

    def get_ref(ref)
      # mock github response
      {
        object: {
          sha: client.commit(repo_name, ref.gsub('heads/', '')).short_id
        }
      }
    end

    def download(path, branch)
      file = client.get_file(repo_name, path, branch.gsub('heads/', ''))

      # mock github response
      {
        content: file.encoding == 'base64' ? Base64.decode64(file.content) : file.content.force_encoding(file.encoding),
        path: path
      }
    end

    def create_status(sha, state, options = {})
      client.update_commit_status(repo_name, sha, state, options)
    rescue ::Gitlab::Error::BadRequest => error
      # Gitlab pipeline may have several jobs and txgh should not override commit statuses set by others
      raise error unless error.message.include?('Cannot transition status')
    end
  end
end
