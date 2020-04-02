module TxghServer
  module Webhooks
    module Git
      class StatusUpdater
        attr_reader :project, :repo, :branch

        def initialize(project, repo, branch)
          @project = project
          @repo = repo
          @branch = branch
        end
      end
    end
  end
end
