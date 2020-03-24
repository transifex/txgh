module Txgh
  class GitRepo
    attr_reader :config, :api

    def initialize(config, api)
      @config = config
      @api = api
    end

    def name
      config['name']
    end

    def branch
      config['branch']
    end

    def tag
      config['tag']
    end

    def process_all_branches?
      branch == 'all'
    end

    def upload_diffs?
      !(diff_point || '').empty?
    end

    def diff_point
      config['diff_point']
    end

    def process_all_tags?
      tag == 'all'
    end

    def should_process_ref?(candidate)
      if Utils.is_tag?(candidate)
        should_process_tag?(candidate)
      else
        should_process_branch?(candidate)
      end
    end

    def git_config_branch
      @git_config_branch ||= begin
        if process_all_branches?
          'all'
        else
          Utils.absolute_branch(branch || 'master')
        end
      end
    end

    def git_config_tag
      @git_config_tag ||= begin
        if process_all_tags?
          'all'
        else
          Utils.absolute_branch(tag) if tag
        end
      end
    end

    def webhook_secret
      config['webhook_secret']
    end

    def webhook_protected?
      !(webhook_secret || '').empty?
    end

    def commit_message
      config['commit_message']
    end

    private

    def should_process_branch?(candidate)
      process_all_branches? || candidate.include?(git_config_branch)
    end

    def should_process_tag?(candidate)
      process_all_tags? || (
        git_config_tag && candidate.include?(git_config_tag)
      )
    end
  end
end
