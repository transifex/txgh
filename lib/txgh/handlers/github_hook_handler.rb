require 'base64'
require 'logger'

module Txgh
  module Handlers
    class GithubHookHandler
      include Txgh::CategorySupport

      attr_reader :project, :repo, :payload, :logger

      def initialize(options = {})
        @project = options.fetch(:project)
        @repo = options.fetch(:repo)
        @payload = options.fetch(:payload)
        @logger = options.fetch(:logger) { Logger.new(STDOUT) }
      end

      def execute
        # Check if the branch in the hook data is the configured branch we want
        logger.info("request github branch: #{branch}")
        logger.info("config github branch: #{github_config_branch}")

        if should_process_branch?
          logger.info('found branch in github request')

          tx_resources = tx_resources_for(branch)
          modified_resources = modified_resources_for(tx_resources)
          modified_resources.merge!(l10n_resources_for(tx_resources))

          if github_config_branch.include?('tags/')
            modified_resources.merge!(tag_resources_for(tx_resources))
          end

          # Handle DBZ 'L10N' special case
          if branch.include?("L10N")
            logger.info('processing L10N tag')

            # Create a new branch off tag commit
            if branch.include?('tags/L10N')
              repo.api.create_ref(repo.name, 'heads/L10N', payload['head_commit']['id'])
            end
          end

          update_resources(modified_resources)
        end
      end

      private

      # For each modified resource, get its content and update the content
      # in Transifex.
      def update_resources(resources)
        resources.each do |tx_resource, commit_sha|
          logger.info('process updated resource')
          github_api = repo.api
          tree_sha = github_api.get_commit(repo.name, commit_sha)['commit']['tree']['sha']
          tree = github_api.tree(repo.name, tree_sha)

          tree['tree'].each do |file|
            logger.info("process each tree entry: #{file['path']}")

            if tx_resource.source_file == file['path']
              logger.info("process resource file: #{tx_resource.source_file}")
              blob = github_api.blob(repo.name, file['sha'])
              content = blob['encoding'] == 'utf-8' ? blob['content'] : Base64.decode64(blob['content'])

              if upload_by_branch?
                upload_by_branch(tx_resource, content)
              else
                upload(tx_resource, content)
              end

              logger.info "updated tx_resource: #{tx_resource.inspect}"
            end
          end
        end
      end

      def upload(tx_resource, content)
        project.api.create_or_update(tx_resource, content)
      end

      def upload_by_branch(tx_resource, content)
        resource_exists = project.api.resource_exists?(tx_resource)

        categories = if resource_exists
          resource = project.api.get_resource(tx_resource.project_slug, tx_resource.resource_slug)
          deserialize_categories(Array(resource['categories']))
        else
          {}
        end

        categories['branch'] ||= branch
        categories['author'] ||= escape_category(
          payload['head_commit']['committer']['name']
        )

        categories = serialize_categories(categories)

        if resource_exists
          project.api.update_details(tx_resource, categories: categories)
          project.api.update_content(tx_resource, content)
        else
          project.api.create(tx_resource, content, categories)
        end
      end

      def tag_resources_for(tx_resources)
        payload['head_commit']['modified'].each_with_object({}) do |modified, ret|
          # logger.info("processing modified file: #{modified}")

          if tx_resources.include?(modified)
            ret[tx_resources[modified]] = payload['head_commit']['id']
          end
        end
      end

      def l10n_resources_for(tx_resources)
        payload['head_commit']['modified'].each_with_object({}) do |modified, ret|
          # logger.info("setting new resource: #{tx_resources[modified].L10N_resource_slug}")

          if tx_resources.include?(modified)
            ret[tx_resources[modified]] = payload['head_commit']['id']
          end
        end
      end

      # Finds the updated resources and maps the most recent commit in which
      # each was modified
      def modified_resources_for(tx_resources)
        payload['commits'].each_with_object({}) do |commit, ret|
          logger.info('processing commit')

          commit['modified'].each do |modified|
            logger.info("processing modified file: #{modified}")

            if tx_resources.include?(modified)
              ret[tx_resources[modified]] = commit['id']
            end
          end
        end
      end

      # Build an index of known Tx resources, by source file
      def tx_resources_for(branch)
        project.resources.each_with_object({}) do |resource, ret|
          logger.info('processing resource')

          # If we're processing by branch, create a branch resource. Otherwise,
          # use the original resource.
          ret[resource.source_file] = if upload_by_branch?
            TxBranchResource.new(resource, branch)
          else
            resource
          end
        end
      end

      def should_process_branch?
        process_all_branches? || (
          branch.include?(github_config_branch) || branch.include?('L10N')
        )
      end

      def github_config_branch
        @github_config_branch = begin
          if repo.branch == 'all'
            repo.branch
          else
            branch = repo.branch || 'master'
            branch.include?('tags/') ? branch : "heads/#{branch}"
          end
        end
      end

      def process_all_branches?
        github_config_branch == 'all'
      end

      alias_method :upload_by_branch?, :process_all_branches?

      def branch
        @ref ||= payload['ref'].sub(/^refs\//, '')
      end
    end
  end
end
