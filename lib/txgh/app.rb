require 'base64'
require 'faraday'
require 'haml'
require 'json'
require 'sinatra'
require 'sinatra/reloader'

module Txgh

  class Application < Sinatra::Base

    use Rack::Auth::Basic, 'Restricted Area' do |username, password|
      username == 'foo' && password == 'bar'
    end

    configure :development do
      register Sinatra::Reloader
    end

    def initialize(app = nil)
      super(app)
    end

    get '/health_check' do
      200
    end

  end

  class Hooks < Sinatra::Base
    # Hooks are unprotected endpoints used for data integration between GitHub and
    # Transifex. They live under the /hooks namespace (see config.ru)

    configure :production do
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    configure :development , :test do
      register Sinatra::Reloader
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    def initialize(app = nil)
      super(app)
    end


    post '/transifex' do
      settings.logger.info('Processing request at /hooks/transifex')
      settings.logger.info(request.inspect)

      Txgh::KeyManager.load_yaml(nil, request['project'])

      project_config = Txgh::KeyManager.transifex_project_config.merge(
        'name' => request['project']
      )

      Txgh::KeyManager.load_yaml(
        Txgh::KeyManager.transifex_project_config['push_translations_to'],
        project_config['name']
      )

      github_config = Txgh::KeyManager.github_repo_config.merge(
        'name' => project_config['push_translations_to']
      )

      transifex_api = Txgh::TransifexApi.instance(
        project_config['api_username'], project_config['api_password']
      )

      github_api = Txgh::GitHubApi.new(
        github_config['api_username'], github_config['api_token']
      )

      github_repo = Txgh::GitHubRepo.new(github_config, github_api)
      project = Txgh::TransifexProject.new(project_config, transifex_api)

      handler = Txgh::Handlers::TransifexHookHandler.new(
        project: project,
        repo: github_repo,
        resource: request['resource'],
        language: request['language'],
        logger: settings.logger
      )

      handler.execute
    end

    post '/github' do
      settings.logger.info('Processing request at /hooks/github')

      payload = if params[:payload]
        settings.logger.info('processing payload from form')
        JSON.parse(params[:payload])
      else
        settings.logger.info("processing payload from request.body")
        JSON.parse(request.body.read)
      end

      github_repo_branch = payload['ref']
      github_repo_name = "#{payload['repository']['owner']['name']}/#{payload['repository']['name']}"

      Txgh::KeyManager.load_yaml(github_repo_name, nil)

      github_config = Txgh::KeyManager.github_repo_config.merge(
        'name' => github_repo_name, 'branch' => github_repo_branch
      )

      Txgh::KeyManager.load_yaml(
        github_config['name'],
        Txgh::KeyManager.github_repo_config['push_source_to'],
      )

      project_config = Txgh::KeyManager.transifex_project_config.merge(
        'name' => github_config['push_source_to']
      )

      transifex_api = Txgh::TransifexApi.instance(
        project_config['api_username'], project_config['api_password']
      )

      github_api = Txgh::GitHubApi.new(
        github_config['api_username'], github_config['api_token']
      )

      github_repo = Txgh::GitHubRepo.new(github_config, github_api)
      project = Txgh::TransifexProject.new(project_config, transifex_api)

      handler = Txgh::Handlers::GithubHookHandler.new(
        project: project,
        repo: github_repo,
        payload: payload,
        logger: settings.logger
      )

      handler.execute
    end
  end
end
