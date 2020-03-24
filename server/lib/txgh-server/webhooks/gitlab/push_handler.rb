require 'set'
require 'octokit'
require 'txgh'

module TxghServer
  module Webhooks
    module Gitlab
      class PushHandler < TxghServer::Webhooks::Github::PushHandler
        def execute
          logger.info("request gitlab branch: #{branch}")
          logger.info("config gitlab branch: #{repo.git_config_branch}")

          if should_process?
            logger.info('found branch in gitlab request')

            pusher.push_resources(added_and_modified_resources) do |tx_resource|
              # block should return categories for the passed-in resource
              { 'author' => attributes.author }
            end

            status_updater.update_status
          end

          respond_with(200, true)
        rescue => e
          status_updater.report_error_and_update_status(e)
          respond_with_error(500, "Internal server error: #{e.message}", e)
        end

        def status_updater
          @status_updater = TxghServer::Webhooks::Gitlab::StatusUpdater.new(project, repo, branch)
        end
      end
    end
  end
end
