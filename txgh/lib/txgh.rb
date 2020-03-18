require 'txgh/errors'
require 'yaml'

module Txgh
  autoload :CategorySupport,       'txgh/category_support'
  autoload :Config,                'txgh/config'
  autoload :DiffCalculator,        'txgh/diff_calculator'
  autoload :EmptyResourceContents, 'txgh/empty_resource_contents'
  autoload :Events,                'txgh/events'
  autoload :GithubApi,             'txgh/github_api'
  autoload :GithubRepo,            'txgh/github_repo'
  autoload :GitlabRepo,            'txgh/gitlab_repo'
  autoload :GithubStatus,          'txgh/github_status'
  autoload :GitlabStatus,          'txgh/gitlab_status'
  autoload :MergeCalculator,       'txgh/merge_calculator'
  autoload :ParseConfig,           'txgh/parse_config'
  autoload :Puller,                'txgh/puller'
  autoload :Pusher,                'txgh/pusher'
  autoload :ResourceCommitter,     'txgh/resource_committer'
  autoload :ResourceContents,      'txgh/resource_contents'
  autoload :ResourceDeleter,       'txgh/resource_deleter'
  autoload :ResourceDownloader,    'txgh/resource_downloader'
  autoload :ResourceUpdater,       'txgh/resource_updater'
  autoload :TransifexApi,          'txgh/transifex_api'
  autoload :TransifexProject,      'txgh/transifex_project'
  autoload :TxBranchResource,      'txgh/tx_branch_resource'
  autoload :TxLogger,              'txgh/tx_logger'
  autoload :TxResource,            'txgh/tx_resource'
  autoload :Utils,                 'txgh/utils'

  DEFAULT_ENV = 'development'

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

    def events
      @events ||= Events.new
    end

    def env
      ENV.fetch('TXGH_ENV', DEFAULT_ENV)
    end
  end

  # default set of tx config providers
  tx_manager.register_provider(providers::FileProvider,   Txgh::Config::TxConfig)
  tx_manager.register_provider(providers::GithubProvider, Txgh::Config::TxConfig)
  tx_manager.register_provider(providers::GitlabProvider, Txgh::Config::TxConfig)
  tx_manager.register_provider(providers::RawProvider,    Txgh::Config::TxConfig, default: true)

  # default set of base config providers
  key_manager.register_provider(providers::FileProvider, YAML)
  key_manager.register_provider(providers::RawProvider,  YAML)
end
