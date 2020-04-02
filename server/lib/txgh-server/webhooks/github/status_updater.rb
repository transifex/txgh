require 'octokit'

module TxghServer
  module Webhooks
    module Github
      class StatusUpdater < TxghServer::Webhooks::Git::StatusUpdater
        def report_error_and_update_status(error)
          error_params = Txgh.events.publish_error!(error)

          Txgh.events.publish_each('github.status.error', error_params) do |status_params|
            if status_params
              update_status_safely do
                Txgh::GithubStatus.error(project, repo, branch, status_params)
              end
            end
          end
        end

        def update_status
          update_status_safely do
            Txgh::GithubStatus.update(project, repo, branch)
          end
        end

        private

        def update_status_safely
          yield
        rescue Octokit::UnprocessableEntity
          # raised because we've tried to create too many statuses for the commit
        rescue Txgh::TransifexNotFoundError
          # raised if transifex resource can't be found
        end
      end
    end
  end
end
