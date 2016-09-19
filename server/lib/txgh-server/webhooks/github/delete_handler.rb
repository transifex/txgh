module TxghServer
  module Webhooks
    module Github
      class DeleteHandler
        include ResponseHelpers

        attr_reader :project, :repo, :logger, :attributes

        def initialize(project, repo, logger, attributes)
          @project = project
          @repo = repo
          @logger = logger
          @attributes = attributes
        end

        def execute
          perform_delete if should_handle_request?
          respond_with(200, true)
        end

        private

        def perform_delete
          deleter.delete_resources
        end

        def deleter
          @deleter ||= Txgh::ResourceDeleter.new(project, repo, branch)
        end

        def should_handle_request?
          # ref_type can be either 'branch' or 'tag' - we only care about branches
          attributes.ref_type == 'branch' &&
            repo.should_process_ref?(branch) &&
            project.auto_delete_resources?
        end

        def branch
          Txgh::Utils.absolute_branch(attributes.ref.sub(/^refs\//, ''))
        end

      end
    end
  end
end
