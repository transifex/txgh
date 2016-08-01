module Txgh
  module Config
    class TxManager
      class << self
        include ProviderSupport

        def tx_config(transifex_project, github_repo, ref = nil)
          options = { github_repo: github_repo, ref: ref }
          scheme, payload = split_uri(transifex_project.tx_config_uri)
          provider_for(scheme).load(payload, options)
        end
      end
    end
  end
end
