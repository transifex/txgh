module Txgh
  module Handlers
    module Triggers
      class PullHandler < Handler

        def execute
          languages.each do |language|
            committer.commit_resource(
              branch_resource, branch, language['language_code']
            )
          end

          respond_with(200, true)
        end

        private

        def committer
          @committer ||= Txgh::ResourceCommitter.new(project, repo, logger)
        end

        def languages
          @languages ||= project.api.get_languages(project.name)
        end

      end
    end
  end
end
