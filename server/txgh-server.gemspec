$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'txgh-server/version'

Gem::Specification.new do |s|
  s.name     = 'txgh-server'
  s.version  = ::TxghServer::VERSION
  s.authors  = ['Matthew Jackowski', 'Cameron Dutro']
  s.email    = ['mattjjacko@gmail.com', 'camertron@gmail.com']
  s.homepage = 'https://github.com/lumoslabs/txgh'

  s.description = s.summary = 'An HTTP server for interacting with txgh.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'mime-types', '~> 2.0'
  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'sinatra-contrib', '~> 1.4'
  s.add_dependency 'rubyzip', '>= 1.0', '<= 1.1.2'
  s.add_dependency 'txgh', '>= 7.0.2'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'txgh-server.gemspec', 'LICENSE']
end
