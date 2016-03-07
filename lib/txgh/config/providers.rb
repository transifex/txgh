module Txgh
  module Config
    module Providers
      autoload :FileProvider, 'txgh/config/providers/file_provider'
      autoload :GitProvider,  'txgh/config/providers/git_provider'
      autoload :RawProvider,  'txgh/config/providers/raw_provider'
    end
  end
end
