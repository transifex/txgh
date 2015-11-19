ENV['RACK_ENV'] = 'test'
require_relative '../bootstrap'
require 'app/app'
require 'test/unit'
require 'rack/test'
require 'tests/github_postbody'
require 'tests/github_postbody_release'

set :environment, :test

class TxghTestCase < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app ||= L10n::Hooks.new
  end

  def test_tx_config_setup
    tx_name = 'txgh-test-1'
    gh_name = 'matthewjackowski/txgh-test-resources'
    Strava::Config::KeyManager.load_yaml(gh_name,tx_name)
    @config = Strava::Config::KeyManager.transifex_project_config
    assert_not_nil @config
    p @config.inspect
    p "Success!"
  end

  def test_gh_config_setup
    tx_name = 'txgh-test-1'
    gh_name = 'matthewjackowski/txgh-test-resources'
    Strava::Config::KeyManager.load_yaml(gh_name,tx_name)
    @config =  Strava::Config::KeyManager.github_repo_config
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


end
