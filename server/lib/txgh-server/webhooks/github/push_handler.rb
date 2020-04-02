module TxghServer
  module Webhooks
    module Github
      class PushHandler < TxghServer::Webhooks::Git::PushHandler
        private

        def status_updater
          @status_updater = TxghServer::Webhooks::Github::StatusUpdater.new(project, repo, branch)
        end
      end
    end
  end
end
