# encoding: UTF-8

require 'cgi'
require 'rake'
require 'rspec'
require 'pry-nav'
require 'txgh'
# require 'vcr'
# require 'webmock/rspec'
# require 'yaml'

# load environment vars
require 'dotenv'
Dotenv.load

# ENV['TX_CONFIG_PATH'] = './spec/fixtures/tx.config'

# VCR.configure do |config|
#   config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
#   config.hook_into :webmock

#   %w(TX_USERNAME TX_PASSWORD GITHUB_USERNAME GITHUB_PASSWORD).each do |var|
#     config.filter_sensitive_data("<#{var}>") do
#       CGI.escape(ENV[var]) if ENV[var]
#     end
#   end
# end

# RSpec.configure do |config|
#   config.before(:each) do
#     allow(Txgh::KeyManager).to(receive(:yaml)) do
#       YAML.load(ERB.new(File.read('spec/fixtures/txgh.yml')).result)
#     end
#   end
# end
