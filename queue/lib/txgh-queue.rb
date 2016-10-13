module TxghQueue
  autoload :Backends,      'txgh-queue/backends'
  autoload :Config,        'txgh-queue/config'
  autoload :ErrorHandlers, 'txgh-queue/error_handlers'
  autoload :Job,           'txgh-queue/job'
  autoload :Status,        'txgh-queue/status'
  autoload :Supervisor,    'txgh-queue/supervisor'
  autoload :Result,        'txgh-queue/result'

  Backends.register('null', TxghQueue::Backends::Null)
  Backends.register('sqs',  TxghQueue::Backends::Sqs)
end
