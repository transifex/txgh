module Txgh
  module Config
    module Providers
      autoload :FileProvider,   'txgh/config/providers/file_provider'
      autoload :GitHubProvider, 'txgh/config/providers/git_hub_provider'
      autoload :RawProvider,    'txgh/config/providers/raw_provider'
    end
  end
end
