require 'json'

class GithubPayloadBuilder
  class << self
    def push_payload(*args)
      GithubPushPayload.new(*args)
    end

    def delete_payload(*args)
      GithubDeletePayload.new(*args)
    end
  end
end

class GithubPayload
  def to_h
    # convert symbolized keys to strings
    JSON.parse(to_json)
  end

  def to_json
    @result.to_json
  end

  protected

  def digits
    @@digits ||= ('a'..'f').to_a + ('0'..'9').to_a
  end

  def generate_timestamp
    Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')
  end

  def generate_sha
    blank_commit_id.gsub(/0/) { digits.sample }
  end

  def blank_commit_id
    '0' * 40
  end
end

class GithubDeletePayload < GithubPayload
  attr_reader :repo, :ref

  def initialize(repo, ref)
    @repo = repo
    @ref = ref

    @result = {
      ref: "refs/#{ref}",
      ref_type: 'branch',
      pusher_type: 'user',

      repository: {
        name: repo.split('/').last,
        full_name: repo,
        owner: {
          login: repo.split('/').first
        }
      },

      sender: {
        login: repo.split('/').first,
        type: 'User'
      }
    }
  end
end

class GithubPushPayload < GithubPayload
  attr_reader :repo, :ref, :before, :after

  DEFAULT_USER = {
    name: 'Test User',
    email: 'test@user.com',
    username: 'testuser'
  }

  def initialize(repo, ref, before = nil, after = nil)
    @repo = repo
    @ref = ref
    @before = before || blank_commit_id
    @after = after || generate_sha

    @result = {
      ref: "refs/#{ref}",
      before: @before,
      after: @after,
      created: true,
      deleted: false,
      forced: true,
      base_ref: nil,
      compare: "https://github.com/#{@repo}/commit/#{@after[0..12]}",
      commits: [],
      repository: {
        name: repo.split('/').last,
        full_name: repo,
        owner: {
          name: repo.split('/').first
        }
      }
    }
  end

  def add_commit(options = {})
    id = if commits.empty? && !options.include?(:id)
      after
    else
      options.fetch(:id) { generate_sha }
    end

    commit_data = {
      id: id,
      distinct: options.fetch(:distinct, true),
      message: options.fetch(:message, 'Default commit message'),
      timestamp: options.fetch(:timestamp) { generate_timestamp },
      url: "https://github.com/#{repo}/commit/#{id}",
      author: options.fetch(:author, DEFAULT_USER),
      committer: options.fetch(:committer, DEFAULT_USER),
      added: options.fetch(:added, []),
      removed: options.fetch(:removed, []),
      modified: options.fetch(:modified, [])
    }

    if commit_data[:id] == after
      @result[:head_commit] = commit_data
    end

    commits << commit_data
  end

  def commits
    @result[:commits]
  end

  def head_commit
    @result[:head_commit]
  end
end
