module Txgh
  module Config
    module Providers
      autoload :FileProvider,   'txgh/config/providers/file_provider'
      autoload :GithubProvider, 'txgh/config/providers/github_provider'
      autoload :GitlabProvider, 'txgh/config/providers/gitlab_provider'
      autoload :RawProvider,    'txgh/config/providers/raw_provider'
    end
  end
end
