$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'txgh/version'

Gem::Specification.new do |s|
  s.name     = 'txgh'
  s.version  = ::Txgh::VERSION
  s.authors  = ['Matthew Jackowski', 'Cameron Dutro']
  s.email    = ['mattjjacko@gmail.com', 'camertron@gmail.com']
  s.homepage = "https://github.com/transifex/txgh"

  s.description = s.summary = 'A server that automatically syncs translation resources between Github and Transifex.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'faraday', '~> 0.9'
  s.add_dependency 'faraday_middleware', '~> 0.10'
  s.add_dependency 'json', '~> 1.8'
  s.add_dependency 'octokit', '~> 4.2'
  s.add_dependency 'puma', '~> 2.15'
  s.add_dependency 'parseconfig', '~> 1.0'
  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'sinatra-contrib', '~> 1.4'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'txgh.gemspec']
end
