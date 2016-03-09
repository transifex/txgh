require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader'

module Txgh

  class Application < Sinatra::Base

    configure :development do
      register Sinatra::Reloader
    end

    def initialize(app = nil)
      super(app)
    end

    get '/health_check' do
      200
    end

    get '/config' do
      config = Txgh::Config::KeyManager.config_from_project(params[:project_slug])
      branch = Utils.absolute_branch(params[:branch])

      begin
        tx_config = Txgh::Config::TxManager.tx_config(
          config.transifex_project, config.github_repo, branch
        )

        data = tx_config.to_h
        data.merge!(branch_slug: Utils.slugify(branch)) if branch

        status 200
        json data: data
      rescue ConfigNotFoundError => e
        status 404
        json [{ error: e.message }]
      rescue => e
        status 500
        json [{ error: e.message }]
      end
    end
  end

  class Hooks < Sinatra::Base
    include Txgh::Handlers
    # Hooks are unprotected endpoints used for data integration between Github and
    # Transifex. They live under the /hooks namespace (see config.ru)

    configure do
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    configure :development do
      register Sinatra::Reloader
    end

    def initialize(app = nil)
      super(app)
    end


    post '/transifex' do
      response = Transifex::RequestHandler.handle_request(request, settings.logger)
      status response.status
      json response.body
    end

    post '/github' do
      response = Github::RequestHandler.handle_request(request, settings.logger)
      status response.status
      json response.body
    end
  end

  class Triggers < Sinatra::Base
    configure do
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    configure :development do
      register Sinatra::Reloader
    end

    patch '/push' do
      response = Txgh::Handlers::Triggers::PushHandler.handle_request(request, settings.logger)
      status response.status
      json response.body
    end

    patch '/pull' do
      response = Txgh::Handlers::Triggers::PullHandler.handle_request(request, settings.logger)
      status response.status
      json response.body
    end
  end
end
