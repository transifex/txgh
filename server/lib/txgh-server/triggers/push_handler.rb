require 'octokit'
require 'txgh'

module TxghServer
  module Triggers
    class PushHandler < Handler

      def execute
        pusher.push_slug(resource_slug)
        update_github_status
        respond_with(200, true)
      end

      private

      def update_github_status
        Txgh::GithubStatus.update(project, repo, branch)
      rescue Octokit::UnprocessableEntity
        # raised because we've tried to create too many statuses for the commit
      rescue Txgh::TransifexNotFoundError
        # raised if transifex resource can't be found
      end

      def pusher
        @pusher ||= Txgh::Pusher.new(project, repo, branch)
      end

    end
  end
end
