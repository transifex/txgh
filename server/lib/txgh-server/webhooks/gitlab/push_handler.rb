require 'set'
require 'octokit'
require 'txgh'

module TxghServer
  module Webhooks
    module Gitlab
      class PushHandler < TxghServer::Webhooks::Github::PushHandler
        def execute
          # TODO
          # Check if the branch in the hook data is the configured branch we want
          logger.info("request github branch: #{branch}")
          logger.info("config github branch: #{repo.github_config_branch}")

          if should_process?
            logger.info('found branch in github request')

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
      end
    end
  end
end
