$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'txgh/version'

Gem::Specification.new do |s|
  s.name     = 'txgh'
  s.version  = ::Txgh::VERSION
  s.authors  = ['Matthew Jackowski', 'Cameron Dutro']
  s.email    = ['mattjjacko@gmail.com', 'camertron@gmail.com']
  s.homepage = 'https://github.com/lumoslabs/txgh'

  s.description = s.summary = 'A library for syncing translation resources between Github and Transifex.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'abroad', '~> 4.6'
  s.add_dependency 'celluloid'
  s.add_dependency 'faraday', '0.17.3'
  s.add_dependency 'faraday_middleware', '0.14.0'
  s.add_dependency 'json', '~> 1.8'
  s.add_dependency 'octokit', '~> 4.2'
  s.add_dependency 'gitlab', '~> 4.14'
  s.add_dependency 'parseconfig', '~> 1.0'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'txgh.gemspec', 'LICENSE']
end
