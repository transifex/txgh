require 'txgh-server'
require 'txgh-queue'

map '/' do
  use TxghServer::Application
  use TxghServer::TriggerEndpoints
  run Sinatra::Base
end

map '/hooks' do
  use TxghServer::WebhookEndpoints
  use TxghQueue::WebhookEndpoints
  run Sinatra::Base
end
