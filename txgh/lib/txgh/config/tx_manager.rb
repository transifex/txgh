module Txgh
  module Config
    class TxManager
      class << self
        include ProviderSupport

        def tx_config(transifex_project, git_repo, ref = nil)
          options = { git_repo: git_repo, ref: ref }
          scheme, payload = split_uri(transifex_project.tx_config_uri)
          provider_for(scheme).load(payload, options)
        end
      end
    end
  end
end
