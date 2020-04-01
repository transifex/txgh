$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'txgh-queue/version'

Gem::Specification.new do |s|
  s.name     = 'txgh-queue'
  s.version  = ::TxghQueue::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'https://github.com/lumoslabs/txgh'

  s.description = s.summary = 'Queue worker for processing Txgh webhooks.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'aws-sdk', '~> 2.0'
  s.add_dependency 'txgh', '>= 7.0.2'
  s.add_dependency 'txgh-server', '>= 4.0.3'
  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'sinatra-contrib', '~> 1.4'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'txgh-queue.gemspec', 'LICENSE']
end
