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

namespace :version do
  task :bump, [:level] do |t, args|
    levels = %w(major minor patch)
    level = args[:level]

    until levels.include?(level)
      STDOUT.write("Indicate version bump level (#{levels.join(', ')}): ")
      level = STDIN.gets.strip

      unless levels.include?(level)
        puts "That's not a valid version bump level, try again."
      end
    end

    level.strip!

    major, minor, patch = Txgh::VERSION.split('.').map(&:to_i)

    case level
      when 'major'
        major += 1; minor = 0; patch = 0
      when 'minor'
        minor += 1; patch = 0
      when 'patch'
        patch += 1
    end

    new_version = [major, minor, patch].join('.')
    puts "Bumping from #{Txgh::VERSION} to #{new_version}"

    # rewrite version.rb
    version_file = './lib/txgh/version.rb'
    contents = File.read(version_file)
    contents.sub!(/VERSION\s*=\s['"][\d.]+['"]$/, "VERSION = '#{new_version}'")
    File.write(version_file, contents)

    # update constant in case other rake tasks run in this process afterwards
    Txgh::VERSION.replace(new_version)
  end
end

DOCKER_REPO = 'quay.io/lumoslabs/txgh'

namespace :publish do
  task :all => %w(
    version:bump
    publish:tag publish:build_docker publish:publish_docker
    publish:build_gem publish:publish_gem
  )

  task :tag do
    system("git tag -a v#{Txgh::VERSION} && git push origin --tags")
  end

  task :build_docker do
    system("docker build -t #{DOCKER_REPO}:latest -t #{DOCKER_REPO}:v#{Txgh::VERSION} .")
  end

  task :publish_docker do
    system("docker push #{DOCKER_REPO}:latest")
    system("docker push #{DOCKER_REPO}:v#{Txgh::VERSION}")
  end

  task :build_gem => [:build]  # use preexisting build task from rubygems/package_task

  task :publish_gem do
    system("gem push pkg/txgh-#{Txgh::VERSION}.gem")
  end
end

task publish: 'publish:all'
