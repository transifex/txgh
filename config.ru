require_relative 'bootstrap'
require 'txgh'

if ENV['TX_CONFIG']
  FileUtils.mkdir_p('./config')
  File.write('./config/tx.config', ENV['TX_CONFIG'])
end

if ENV['TX_YAML']
  FileUtils.mkdir_p('./config')
  File.write('./config/txgh.yml', ENV['TX_YAML'])
end

map '/' do
  use Txgh::Application
  run Sinatra::Base
end

map '/hooks' do
  use Txgh::Hooks
  run Sinatra::Base
end
