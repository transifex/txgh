module TxghServer
  module Webhooks
    module Gitlab
      class PushHandler < TxghServer::Webhooks::Git::PushHandler
        private

        def status_updater
          @status_updater = TxghServer::Webhooks::Gitlab::StatusUpdater.new(project, repo, branch)
        end
      end
    end
  end
end
