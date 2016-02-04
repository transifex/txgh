require 'base64'
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
    # Hooks are unprotected endpoints used for data integration between Github and
    # Transifex. They live under the /hooks namespace (see config.ru)

    configure :production do
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    configure :development, :test do
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

      config = Txgh::KeyManager.config_from_project(request['project'])

      handler = transifex_handler_for(
        project: config.transifex_project,
        repo: config.github_repo,
        resource_slug: request['resource'],
        language: request['language'],
        logger: settings.logger
      )

      handler.execute
      status 200
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

      github_repo_name = "#{payload['repository']['owner']['name']}/#{payload['repository']['name']}"
      config = Txgh::KeyManager.config_from_repo(github_repo_name)

      handler = github_handler_for(
        project: config.transifex_project,
        repo: config.github_repo,
        payload: payload,
        logger: settings.logger
      )

      handler.execute
      status 200
    end

    private

    def transifex_handler_for(options)
      Txgh::Handlers::TransifexHookHandler.new(options)
    end

    def github_handler_for(options)
      Txgh::Handlers::GithubHookHandler.new(options)
    end
  end

  class Triggers < Sinatra::Base
    configure :production do
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    configure :development, :test do
      register Sinatra::Reloader
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    get '/:project_slug/:resource_slug/push/:branch' do
      config = Txgh::KeyManager.config_from_project(params[:project_slug])
      tx_config = Txgh::KeyManager.tx_config(
        config.transifex_project, config.github_repo, params[:branch]
      )

      updater = Txgh::ResourceUpdater.new(
        config.transifex_project, config.github_repo, settings.logger
      )

      resource = tx_config.resource(params[:resource_slug], params[:branch])
      updater.update_resources(resource)
    end

    get '/:project_slug/:resource_slug/pull/:branch' do
    end
  end
end
