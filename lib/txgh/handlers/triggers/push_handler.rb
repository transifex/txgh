module Txgh
  module Handlers
    module Triggers
      class PushHandler < Handler

        def execute
          ref = repo.api.get_ref(repo.name, branch)
          updater.update_resource(branch_resource, ref[:object][:sha])
          respond_with(200, true)
        end

        private

        def updater
          @updater ||= Txgh::ResourceUpdater.new(project, repo, logger)
        end

      end
    end
  end
end
