module Txgh
  class GithubRepo
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

    def process_all_branches?
      branch == 'all'
    end

    def upload_diffs?
      !(diff_point || '').empty?
    end

    def diff_point
      config['diff_point']
    end

    def should_process_branch?(candidate)
      process_all_branches? ||
        candidate.include?(github_config_branch) ||
        candidate.include?('L10N')
    end

    def github_config_branch
      @github_config_branch ||= begin
        if process_all_branches?
          'all'
        else
          Utils.absolute_branch(branch || 'master')
        end
      end
    end

    def webhook_secret
      config['webhook_secret']
    end

    def webhook_protected?
      !(webhook_secret || '').empty?
    end
  end
end
