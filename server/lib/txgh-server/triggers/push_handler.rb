module TxghServer
  module Triggers
    class PushHandler < Handler

      def execute
        pusher.push_slug(resource_slug)
        respond_with(200, true)
      end

      private

      def pusher
        @pusher ||= Txgh::Pusher.new(project, repo, branch)
      end

    end
  end
end
