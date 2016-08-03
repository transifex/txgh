require 'logger'

module TxghServer
  module Webhooks
    module Github
      class Handler
        include ResponseHelpers

        attr_reader :project, :repo, :payload, :logger

        def initialize(options = {})
          @project = options.fetch(:project)
          @repo = options.fetch(:repo)
          @payload = options.fetch(:payload)
          @logger = options.fetch(:logger) { Logger.new(STDOUT) }
        end
      end
    end
  end
end
