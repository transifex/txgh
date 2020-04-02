require 'octokit'
require 'txgh'

module TxghServer
  module Triggers
    class PullHandler < Handler

      def execute
        puller.pull_slug(resource_slug)
        repo.is_a?(Txgh::GithubRepo) ? update_github_status : update_gitlab_status
        respond_with(200, true)
      end

      private

      def puller
        @puller ||= Txgh::Puller.new(project, repo, branch)
      end
    end
  end
end
