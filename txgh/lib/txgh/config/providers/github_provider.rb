module Txgh
  module Config
    module Providers
      class GithubProvider
        SCHEME = 'git'

        class << self
          def supports?(scheme)
            scheme == SCHEME
          end

          def load(payload, parser, options = {})
            new(payload, parser, options).config
          end

          def scheme
            SCHEME
          end
        end

        attr_reader :payload, :parser

        def initialize(payload, parser, options = {})
          @payload = payload
          @parser = parser
          @ref = options[:ref]
          @git_repo = options[:git_repo]
        end

        def config
          parser.load(download)
        end

        private

        def download
          git_repo.api.download(payload, ref)[:content]
        rescue Octokit::NotFound
          raise Txgh::GitConfigNotFoundError, "Config file #{payload} not found in #{ref}"
        end

        def ref
          unless @ref
            raise TxghError,
              "TX_CONFIG specified a file from git but did not provide a ref."
          end

          @ref
        end

        def git_repo
          unless @git_repo
            raise TxghError,
              "TX_CONFIG specified a file from git but did not provide a repo."
          end

          @git_repo
        end
      end
    end
  end
end
