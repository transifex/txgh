require 'base64'
require 'config/key_manager'
require 'faraday'
require 'haml'
require 'json'
require 'tx_logger'
require 'sinatra'
require 'sinatra/reloader'
require 'strava/l10n/github_repo'
require 'strava/l10n/transifex_project'

module L10n

  class Application < Sinatra::Base

    use Rack::Auth::Basic, 'Restricted Area' do |username, password|
      username == 'foo' and password == 'bar'
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
      settings.logger.info "Processing request at /hook/transifex"
      settings.logger.info request.inspect
      # Only do something if the translation is complete
      if request['translated'] == '100'
        settings.logger.info "Web hook has translated = 100"
        transifex_project = Strava::L10n::TransifexProject.new(request['project'])
        tx_resource = transifex_project.resource(request['resource'])
        settings.logger.info request['resource']
        # Do not update the source
        unless request['language'] == tx_resource.source_lang
          settings.logger.info "request language matches resource"
          translation = transifex_project.api.download(tx_resource, request['language'])
          if tx_resource.lang_map(request['language']) != request['language']
            settings.logger.info "request language is in lang_map and is not in request"
            translation_path = tx_resource.translation_path(tx_resource.lang_map(request['language']))
          else
            settings.logger.info "request language is in lang_map and is in request or is nil"
            translation_path = tx_resource.translation_path(transifex_project.lang_map(request['language']))
          end
          github_branch = transifex_project.github_repo.config.fetch('branch','master');
          settings.logger.info "make github commit with params:"+transifex_project.github_repo.name + "||" + github_branch + "||" + translation_path + "||" + translation
          transifex_project.github_repo.api.commit(
          transifex_project.github_repo.name, github_branch, translation_path, translation)
        end
      end
    end

    post '/github' do
      settings.logger.info "Processing request at /hook/github"
      settings.logger.info request.inspect
      if params[:payload] != nil
        settings.logger.info "processing payload from form"
        hook_data = JSON.parse(params[:payload], symbolize_names: true)
      else
        settings.logger.info "processing payload from request.body"
        hook_data = JSON.parse(request.body.read, symbolize_names: true)
      end
      github_repo_branch = "#{hook_data[:ref]}"
      github_repo_name = "#{hook_data[:repository][:owner][:name]}/#{hook_data[:repository][:name]}"
      github_repo = Strava::L10n::GitHubRepo.new(github_repo_name)
      transifex_project = github_repo.transifex_project
      github_config_branch = github_repo.config.fetch('branch', 'master')
      # Check if the branch in the hook data is the configured branch we want
      settings.logger.info "github branch:" + github_repo_branch
      if github_repo_branch == "refs/heads/#{github_config_branch}"
        settings.logger.info "found branch in github request"
        # Build an index of known Tx resources, by source file
        tx_resources = {}
        transifex_project.resources.each do |resource|
          settings.logger.info "processing resource"
          tx_resources[resource.source_file] = resource
        end

        # Find the updated resources and maps the most recent commit in which
        # each was modified
        updated_resources = {}
        hook_data[:commits].each do |commit|
          settings.logger.info "processing commit"
          commit[:modified].each do |modified|
            settings.logger.info "processing modified file:"+modified
            updated_resources[tx_resources[modified]] = commit[:id] if tx_resources.include?(modified)
          end
        end
       
        # For each modified resource, get its content and updates the content
        # in Transifex.
        updated_resources.each do |tx_resource, commit_sha|
          settings.logger.info "process updated resource"
          github_api = github_repo.api
          tree_sha = github_api.get_commit(github_repo_name, commit_sha)[:commit][:tree][:sha]
          tree = github_api.tree(github_repo_name, tree_sha)

          tree[:tree].each do |file|
            settings.logger.info "process each file"
            if tx_resource.source_file == file[:path]
              settings.logger.info "resource matches the file"
              blob = github_api.blob(github_repo_name, file[:sha])
              content = blob[:encoding] == 'utf-8' ? blob[:content] : Base64.decode64(blob[:content])
              transifex_project.api.update(tx_resource, content)
              settings.logger.info 'updated tx_resource:'  + tx_resource.inspect
            end
          end
        end
        200
      end
    end
  end
end
