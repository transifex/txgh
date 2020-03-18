module Txgh
  module Config
    module Providers
      class GitlabProvider < Txgh::Config::Providers::GithubProvider
        def initialize(payload, parser, options = {})
          @payload = payload
          @parser = parser
          @ref = options[:ref]
          @gitlab_repo = options[:gitlab_repo]
        end

        private

        def download
          gitlab_repo.api.download(payload, ref)[:content]
        rescue Gitlab::Error::NotFound
          raise Txgh::GitConfigNotFoundError, "Config file #{payload} not found in #{ref}"
        end

        def gitlab_repo
          unless @gitlab_repo
            raise TxghError,
              "TX_CONFIG specified a file from git but did not provide a repo."
          end

          @gitlab_repo
        end
      end
    end
  end
end
