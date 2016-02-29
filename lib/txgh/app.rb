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
      status_code, body = Transifex::RequestHandler.handle_request(
        request, settings.logger
      )

      status status_code
      json body
    end

    post '/github' do
      status_code, body = Github::RequestHandler.handle_request(
        request, settings.logger
      )

      status status_code
      json body
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
      config = Txgh::KeyManager.config_from_project(params[:project_slug])
      branch = Utils.absolute_branch(params[:branch])

      tx_config = Txgh::KeyManager.tx_config(
        config.transifex_project, config.github_repo, branch
      )

      updater = Txgh::ResourceUpdater.new(
        config.transifex_project, config.github_repo, settings.logger
      )

      resource = tx_config.resource(params[:resource_slug])
      branch_resource = TxBranchResource.new(resource, branch)
      ref = config.github_repo.api.get_ref(config.github_repo.name, branch)
      updater.update_resource(branch_resource, ref[:object][:sha])
      status 200
    end

    patch '/pull' do
      config = Txgh::KeyManager.config_from_project(params[:project_slug])
      branch = Utils.absolute_branch(params[:branch])

      tx_config = Txgh::KeyManager.tx_config(
        config.transifex_project, config.github_repo, branch
      )

      committer = Txgh::ResourceCommitter.new(
        config.transifex_project, config.github_repo, settings.logger
      )

      resource = tx_config.resource(params[:resource_slug])
      branch_resource = TxBranchResource.new(resource, branch)
      languages = config.transifex_project.api.get_languages(params[:project_slug])

      languages.each do |language|
        committer.commit_resource(
          branch_resource, branch, language['language_code']
        )
      end

      status 200
    end
  end
end
