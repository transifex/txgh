require 'base64'
require 'config/key_manager'
require 'faraday'
require 'haml'
require 'json'
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

    def initialize(app)
      super(app)
    end

    # This could implement the website for doing manual pushes,
    # check status of files on Transifex, etc...

    get '/health_check' do
      200
    end
  end

  class Hooks < Sinatra::Base
    # Hooks are unprotected endpoints used for data integration between GitHub and
    # Transifex. They live under the /hooks namespace (see config.ru)

    configure :development do
      register Sinatra::Reloader
    end

    def initialize(app)
      super(app)
    end

    post '/transifex' do
      # Only do something if the translation is complete
      if request['translated'] == '100'
        transifex_project = Strava::L10n::TransifexProject.new(request['project'])
        tx_resource = transifex_project.resource(request['resource'])

        # Do not update the source
        unless request['language'] == tx_resource.source_lang
          translation = transifex_project.api.download(tx_resource, request['language'])
          translation_path = tx_resource.translation_path(transifex_project.lang_map(request['language']))
          transifex_project.github_repo.api.commit(
              transifex_project.github_repo.name, translation_path, translation)
        end
      end
    end

    post '/github' do
      hook_data = JSON.parse(params[:payload], symbolize_names: true)
      # We only care about the master branch
      if hook_data[:ref] == 'refs/heads/master'
        github_repo_name = "#{hook_data[:repository][:owner][:name]}/#{hook_data[:repository][:name]}"
        github_repo = Strava::L10n::GitHubRepo.new(github_repo_name)
        transifex_project = github_repo.transifex_project

        # Build an index of known Tx resources, by source file
        tx_resources = {}
        transifex_project.resources.each do |resource|
          tx_resources[resource.source_file] = resource
        end

        puts tx_resources.inspect

        # Find the updated resources and maps the most recent commit in which
        # each was modified
        updated_resources = {}
        hook_data[:commits].each do |commit|
          commit[:modified].each do |modified|
            updated_resources[tx_resources[modified]] = commit[:id] if tx_resources.include?(modified)
          end
        end

        # For each modified resource, get its content and updates the content
        # in Transifex.
        updated_resources.each do |tx_resource, commit_sha|
          github_api = github_repo.api
          tree_sha = github_api.get_commit(github_repo_name, commit_sha)[:commit][:tree][:sha]
          tree = github_api.tree(github_repo_name, tree_sha)
          tree[:tree].each do |file|
            if tx_resource.source_file == file[:path]
              blob = github_api.blob(github_repo_name, file[:sha])
              content = blob[:encoding] == 'utf-8' ? blob[:content] : Base64.decode64(blob[:content])
              transifex_project.api.update(tx_resource, content)
            end
          end
        end
      end
      201
    end
  end
end
