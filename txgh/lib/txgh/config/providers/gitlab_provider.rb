module Txgh
  module Config
    module Providers
      class GitlabProvider < GitProvider

        private

        def download
          gitlab_repo.api.download(payload, ref)[:content]
        rescue ::Gitlab::Error::NotFound
          raise Txgh::GitConfigNotFoundError, "Config file #{payload} not found in #{ref}"
        end
      end
    end
  end
end
