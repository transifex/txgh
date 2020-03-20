module TxghServer
  module Webhooks
    module Gitlab
      class DeleteHandler < TxghServer::Webhooks::Github::DeleteHandler
        private

        def should_handle_request?
          repo.should_process_ref?(branch) && project.auto_delete_resources?
        end
      end
    end
  end
end
