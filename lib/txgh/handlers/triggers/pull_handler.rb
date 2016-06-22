module Txgh
  module Handlers
    module Triggers
      class PullHandler < Handler

        def execute
          puller.pull_slug(resource_slug)
          respond_with(200, true)
        end

        private

        def puller
          @puller ||= Txgh::Puller.new(project, repo, branch)
        end

      end
    end
  end
end
