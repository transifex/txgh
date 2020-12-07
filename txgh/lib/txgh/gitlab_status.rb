module Txgh
  class GitlabStatus < Txgh::GitStatus
    class << self
      def update(project, repo, branch)
        branch = Txgh::Utils.url_safe_relative_branch(branch)
        new(project, repo, branch).update
      end
    end
  end
end
