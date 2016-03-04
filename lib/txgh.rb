require 'txgh/errors'
require 'yaml'

module Txgh
  autoload :Application,          'txgh/app'
  autoload :CategorySupport,      'txgh/category_support'
  autoload :Config,               'txgh/config'
  autoload :GithubApi,            'txgh/github_api'
  autoload :GithubRepo,           'txgh/github_repo'
  autoload :GithubRequestAuth,    'txgh/github_request_auth'
  autoload :Handlers,             'txgh/handlers'
  autoload :Hooks,                'txgh/app'
  autoload :ParseConfig,          'txgh/parse_config'
  autoload :ResourceCommitter,    'txgh/resource_committer'
  autoload :ResourceUpdater,      'txgh/resource_updater'
  autoload :ResponseHelpers,      'txgh/response_helpers'
  autoload :TransifexApi,         'txgh/transifex_api'
  autoload :TransifexProject,     'txgh/transifex_project'
  autoload :TransifexRequestAuth, 'txgh/transifex_request_auth'
  autoload :Triggers,             'txgh/app'
  autoload :TxBranchResource,     'txgh/tx_branch_resource'
  autoload :TxLogger,             'txgh/tx_logger'
  autoload :TxResource,           'txgh/tx_resource'
  autoload :Utils,                'txgh/utils'

  class << self
    def tx_manager
      Txgh::Config::TxManager
    end

    def key_manager
      Txgh::Config::KeyManager
    end

    def providers
      Txgh::Config::Providers
    end
  end

  # default set of tx config providers
  tx_manager.register_provider(providers::FileProvider, Txgh::Config::TxConfig)
  tx_manager.register_provider(providers::GitProvider,  Txgh::Config::TxConfig)
  tx_manager.register_provider(providers::RawProvider,  Txgh::Config::TxConfig)

  # default set of base config providers
  key_manager.register_provider(providers::FileProvider, YAML)
  key_manager.register_provider(providers::RawProvider,  YAML)
end
