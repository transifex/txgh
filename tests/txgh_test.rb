$:.push('lib')

ENV['RACK_ENV'] = 'test'
require_relative '../bootstrap'
require 'pry-nav'
require 'txgh'
require 'txgh/app'
require 'test/unit'
require 'rack/test'
require 'tests/github_postbody'
require 'tests/github_postbody_release'
require 'tests/github_postbody_l10n'

require 'dotenv'
Dotenv.load

set :environment, :test

class TxghTestCase < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app ||= Txgh::Hooks.new
  end

  def test_tx_config_setup
    tx_name = 'txgh-test-1'
    gh_name = 'matthewjackowski/txgh-test-resources'
    Txgh::KeyManager.load_yaml(gh_name,tx_name)
    @config = Txgh::KeyManager.transifex_project_config
    assert_not_nil @config
    p @config.inspect
    p "Success!"
  end

  def test_gh_config_setup
    tx_name = 'txgh-test-1'
    gh_name = 'matthewjackowski/txgh-test-resources'
    Txgh::KeyManager.load_yaml(gh_name,tx_name)
    @config =  Txgh::KeyManager.github_repo_config
    assert_not_nil @config
    p @config.inspect
    p "Success!"
  end

  def test_transifex_hook_endpoint
    data = '{"project": "txgh-test-1","resource": "samplepo","language": "el_GR","translated": 100}'
    post '/transifex', JSON.parse(data)
    assert last_response.ok?, last_response.inspect
    p "Success!"
  end

  def test_github_hook_endpoint
    data = GITHUB_POSTBODY
    data = {"payload" => data}
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    assert last_response.ok?, last_response.inspect
    p "Success!"
  end

  def test_github_release_hook_endpoint
    data = GITHUB_POSTBODY_RELEASE
    data = {"payload" => data}
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    assert last_response.ok?, last_response.inspect
    p "Success!"
  end

  def test_github_l10n_hook_endpoint
    data = GITHUB_POSTBODY_L10N
    data = {"payload" => data}
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    assert last_response.ok?, last_response.inspect
    p "Success!"
  end
end
