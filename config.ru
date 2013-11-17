$:.unshift File::dirname(__FILE__)
$:.unshift "#{File::dirname(__FILE__)}/lib"

require './app/app'

map '/' do
  use L10n::Application
  run Sinatra::Base
end

map '/hooks' do
   use L10n::Hooks
  run Sinatra::Base
end
