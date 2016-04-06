require 'rspec/core/rake_task'
require 'rubygems/package_task'
require './lib/txgh'

Bundler::GemHelper.install_tasks

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task default: :spec

namespace :spec do
  desc 'Run full spec suite'
  task full: [:full_spec_env, :spec]

  task :full_spec_env do
    ENV['FULL_SPEC'] = 'true'
  end
end
