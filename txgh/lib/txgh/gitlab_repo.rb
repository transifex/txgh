module Txgh
  class GitlabRepo < Txgh::GithubRepo
    def gitlab_config_branch
      @gitlab_config_branch ||= process_all_branches? ? 'all' : Utils.absolute_branch(branch || 'master')
    end

    def gitlab_config_tag
      @gitlab_config_tag ||= process_all_tags? ? 'all' : Utils.absolute_branch(tag) if tag
    end

    private

    def should_process_branch?(candidate)
      process_all_branches? || candidate.include?(gitlab_config_branch)
    end

    def should_process_tag?(candidate)
      process_all_tags? || (
        gitlab_config_tag && candidate.include?(gitlab_config_tag)
      )
    end
  end
end
