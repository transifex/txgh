require 'base64'
require 'json'
require 'sinatra'
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
        handler = transifex_handler_for(
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

      if authenticated_github_request?(config.github_repo, request)
        handler = github_handler_for(
          project: config.transifex_project,
          repo: config.github_repo,
          payload: payload,
          logger: settings.logger
        )

        handler.execute
        status 200
      else
        status 401
      end
    end

    private

    def authenticated_github_request?(repo, request)
      if repo.webhook_protected?
        GithubRequestAuth.authentic_request?(
          request, repo.webhook_secret
        )
      else
        true
      end
    end

    def authenticated_transifex_request?(project, request)
      if project.webhook_protected?
        TransifexRequestAuth.authentic_request?(
          request, project.webhook_secret
        )
      else
        true
      end
    end

    def transifex_handler_for(options)
      Txgh::Handlers::TransifexHookHandler.new(options)
    end

    def github_handler_for(options)
      Txgh::Handlers::GithubHookHandler.new(options)
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
