ENV['RACK_ENV'] = 'test'
require_relative '../bootstrap'
require 'app/app'
require 'test/unit'
require 'rack/test'

require 'config_env'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app ||= L10n::Application.new
  end

  def test_tx_config_setup
    @name = 'project_slug'
    @config = Strava::Config::KeyManager.transifex_project_config(@name)
    @mconfig = {"tx_config"=>"/path/to/.tx/config, see below if you do not have any",
                "api_username"=>"<Transifex API username>",
                "api_password"=>"<Transifex API password>",
                "push_translations_to"=>"<full/github/repo/name>"}

    assert_equal @mconfig, @config
    p "Success!"
  end

  def test_gh_config_setup
    @name = 'ghreponame'
    @config =  Strava::Config::KeyManager.github_repo_config(@name)
    @mconfig = {"api_username"=>"<your Github API username>",
                "api_token"=>"<your Github API token>",
                "push_source_to"=>"ios-transifex-demo"}

    assert_equal @mconfig, @config
    p "Success!"
  end

  def test_txgh_status_returns_status
    basic_authorize 'foo', 'bar'
    get '/status'
    assert last_response.ok?, last_request.url
    assert_equal 'ok', last_response.body
    p "Success!"
  end

=begin
  def test_transifex_returns_hello_world
    '/transifex'
    assert last_response.ok?
    assert_equal 'Hello World!', last_response.body
  end

  def test_github_returns_hello_world
    '/github'
    assert last_response.ok?
    assert_equal 'Hello World!', last_response.body
  end
=end

=begin

  def test_tx_config_setup
    @config = Strava::L10n::TxConfig.new('/path/to/.tx/config')
    print config
    assert config
  end

  def test_github_repo_setup
    @repo = Strava::L10n::GitHubRepo.new('translations/directory')
    print repo
    assert repo
  end

  def test_tx_api_setup
    @api = Strava::L10n::TransifexApi.instance('username', 'password')
    print api
    assert api
  end

  def test_tx_project_setup
    @project = Strava::L10n::TransifexProject.new('source/directory')
    print project
    assert project
  end

  def test_gh_api_setup
    @api = @api || Strava::L10n::GitHubApi.new('api_username','api_token')
    print api
    assert api
  end

=end

end
