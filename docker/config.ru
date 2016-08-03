require 'txgh-server'

map '/' do
  use TxghServer::Application
  use TxghServer::TriggerEndpoints
  run Sinatra::Base
end

map '/hooks' do
  use TxghServer::WebhookEndpoints
  run Sinatra::Base
end
