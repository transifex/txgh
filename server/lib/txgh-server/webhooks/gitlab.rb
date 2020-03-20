module TxghServer
  module Webhooks
    module Gitlab
      autoload :BlankAttributes,  'txgh-server/webhooks/gitlab/blank_attributes'
      autoload :DeleteAttributes, 'txgh-server/webhooks/gitlab/delete_attributes'
      autoload :DeleteHandler,    'txgh-server/webhooks/gitlab/delete_handler'
      autoload :Handler,          'txgh-server/webhooks/gitlab/handler'
      autoload :PushHandler,      'txgh-server/webhooks/gitlab/push_handler'
      autoload :PushAttributes,   'txgh-server/webhooks/gitlab/push_attributes'
      autoload :RequestHandler,   'txgh-server/webhooks/gitlab/request_handler'
      autoload :StatusUpdater,    'txgh-server/webhooks/gitlab/status_updater'
    end
  end
end
