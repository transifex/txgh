module Txgh
  module Handlers
    autoload :Github,            'txgh/handlers/github'
    autoload :Response,          'txgh/handlers/response'
    autoload :StreamResponse,    'txgh/handlers/stream_response'
    autoload :TgzStreamResponse, 'txgh/handlers/tgz_stream_response'
    autoload :Transifex,         'txgh/handlers/transifex'
    autoload :Triggers,          'txgh/handlers/triggers'
    autoload :ZipStreamResponse, 'txgh/handlers/zip_stream_response'
  end
end
