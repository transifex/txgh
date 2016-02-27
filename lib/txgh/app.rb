require 'base64'
require 'json'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader'
require 'uri'

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
      settings.logger.info('Processing request at /hooks/transifex')
      settings.logger.info(request.inspect)

      payload = Hash[URI.decode_www_form(request.body.read)]
      config = Txgh::KeyManager.config_from_project(payload['project'])

      if authenticated_transifex_request?(config.transifex_project, request)
        handler = Txgh::Handlers::TransifexHookHandler.new(
          project: config.transifex_project,
          repo: config.github_repo,
          resource_slug: payload['resource'],
          language: payload['language'],
          logger: settings.logger
        )

        handler.execute
        status 200
      else
        status 401
      end
    end

    post '/github' do
      response = Txgh::Handlers::Github::RequestHandler.handle_request(
        request, settings.logger
      )

      status response.status
      json response.body
    end

    private

    def authenticated_transifex_request?(project, request)
      if project.webhook_protected?
        TransifexRequestAuth.authentic_request?(
          request, project.webhook_secret
        )
      else
        true
      end
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
