module Txgh
  module Handlers
    autoload :GithubHookHandler,    'txgh/handlers/github_hook_handler'
    autoload :TransifexHookHandler, 'txgh/handlers/transifex_hook_handler'
  end
end
