require 'txgh'

module TxghServer
  autoload :Application,          'txgh-server/application'
  autoload :DownloadHandler,      'txgh-server/download_handler'
  autoload :GithubRequestAuth,    'txgh-server/github_request_auth'
  autoload :GitlabRequestAuth,    'txgh-server/gitlab_request_auth'
  autoload :Response,             'txgh-server/response'
  autoload :ResponseHelpers,      'txgh-server/response_helpers'
  autoload :StreamResponse,       'txgh-server/stream_response'
  autoload :TgzStreamResponse,    'txgh-server/tgz_stream_response'
  autoload :TransifexRequestAuth, 'txgh-server/transifex_request_auth'
  autoload :Triggers,             'txgh-server/triggers'
  autoload :Webhooks,             'txgh-server/webhooks'
  autoload :ZipStreamResponse,    'txgh-server/zip_stream_response'
end
