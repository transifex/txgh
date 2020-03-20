require 'octokit'
require 'txgh'

module TxghServer
  module Triggers
    class PushHandler < Handler

      def execute
        pusher.push_slug(resource_slug)
        repo.is_a?(Txgh::GithubRepo) ? update_github_status : update_gitlab_status
        respond_with(200, true)
      end

      private

      def pusher
        @pusher ||= Txgh::Pusher.new(project, repo, branch)
      end
    end
  end
end
