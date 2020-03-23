require 'json'

class GitlabPayloadBuilder
  class << self
    def push_payload(*args)
      GitlabPushPayload.new(*args)
    end

    def delete_payload(*args)
      GitlabDeletePayload.new(*args)
    end
  end
end

class GitlabPayload
  def to_h
    # convert symbolized keys to strings
    JSON.parse(to_json)
  end

  def to_json
    @result.to_json
  end

  def merge!(hash)
    @result.merge!(hash)
  end

  private

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

class GitlabDeletePayload < GitlabPayload
  attr_reader :repo, :ref

  def initialize(repo, ref)
    @repo = repo
    @ref = ref

    @result = {
      ref: "refs/#{ref}",
      before: generate_sha,
      after: blank_commit_id,
      project: {
        path_with_namespace: repo
      },
      repository: {
        name: repo.split('/').last
      }
    }
  end
end

class GitlabPushPayload < GitlabPayload
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
      commits: [],
      user_name: DEFAULT_USER[:username],
      project: {
        path_with_namespace: repo
      },
      repository: {
        name: repo.split('/').last
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
