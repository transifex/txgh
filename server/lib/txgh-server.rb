require 'txgh'

module TxghServer
  autoload :Application,          'txgh-server/application'
  autoload :DownloadHandler,      'txgh-server/download_handler'

  # @TODO: refactor/remove
  autoload :WebhookEndpoints,     'txgh-server/application'

  autoload :GithubRequestAuth,    'txgh-server/github_request_auth'
  autoload :Response,             'txgh-server/response'
  autoload :ResponseHelpers,      'txgh-server/response_helpers'
  autoload :StreamResponse,       'txgh-server/stream_response'
  autoload :TgzStreamResponse,    'txgh-server/tgz_stream_response'
  autoload :TransifexRequestAuth, 'txgh-server/transifex_request_auth'

  # @TODO: refactor/remove
  autoload :TriggerEndpoints,     'txgh-server/application'

  autoload :Triggers,             'txgh-server/triggers'
  autoload :Webhooks,             'txgh-server/webhooks'
  autoload :ZipStreamResponse,    'txgh-server/zip_stream_response'
end
