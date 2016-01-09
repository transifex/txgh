module Txgh
  autoload :Application,      'txgh/app'
  autoload :GitHubApi,        'txgh/github_api'
  autoload :GitHubRepo,       'txgh/github_repo'
  autoload :Hooks,            'txgh/app'
  autoload :KeyManager,       'txgh/key_manager'
  autoload :TransifexApi,     'txgh/transifex_api'
  autoload :TransifexProject, 'txgh/transifex_project'
  autoload :TxConfig,         'txgh/tx_config'
  autoload :TxLogger,         'txgh/tx_logger'
  autoload :TxResource,       'txgh/tx_resource'
end
