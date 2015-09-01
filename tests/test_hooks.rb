ENV['RACK_ENV'] = 'test'
require_relative '../bootstrap'
require 'app/app'
require 'test/unit'
require 'rack/test'
require 'tests/github_postbody'

require 'config_env'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app ||= L10n::Hooks.new
  end

  def test_tx_config_setup
    @name = 'txgh-test-1'
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

  def test_transifex_hook_endpoint
    data = '{"project": "txgh-test-1","resource": "samplepo","language": "el_GR","translated": 100}'
    post '/transifex', JSON.parse(data)
    assert last_response.ok?, last_response.inspect
    assert_equal '["ref", "refs/heads/master"]["url", "https://api.github.com/repos/matthewjackowski/txgh-test-resources/git/refs/heads/master"]["object", #<Hashie::Mash sha="46d8c6a1f0ee875044b6e11d64a43766602ab3a2" type="commit" url="https://api.github.com/repos/matthewjackowski/txgh-test-resources/git/commits/46d8c6a1f0ee875044b6e11d64a43766602ab3a2">]', last_response.body
  end

  def test_github_hook_endpoint
    data = GITHUB_POSTBODY
    data = {"payload" => data}
    header 'content-type', 'application/x-www-form-urlencoded'
    post '/github', data
    assert last_response.ok?, last_response.inspect
    assert_equal '', last_response.body
  end

  def test_tx_project_setup
    @project = Strava::L10n::TransifexProject.new('txproject')
    @mproject = '{"something":"otherthing"}'
#    assert_equal @mproject, @project
    @resource = @project.resource('core')
    
    @mresource = '{"something":"otherthing"}'
    assert_equal @mresource, @resource
    @slang = @resource.source_lang
    @mlang = 'en'
    assert_equal @mlang, @slang
    p "Success!"
  end

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

  def test_gh_api_setup
    @api = @api || Strava::L10n::GitHubApi.new('api_username','api_token')
    print api
    assert api
  end

=end

end
