module Txgh
  module Config
    module Providers
      class GithubProvider < GitProvider

        private

        def download
          git_repo.api.download(payload, ref)[:content]
        rescue Octokit::NotFound
          raise Txgh::GitConfigNotFoundError, "Config file #{payload} not found in #{ref}"
        end
      end
    end
  end
end
