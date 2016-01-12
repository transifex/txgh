require 'logger'

module Txgh
  module Handlers
    class GithubHookHandler
      attr_reader :project, :repo, :branch, :payload, :logger

      def initialize(options = {})
        @project = options.fetch(:project)
        @repo = options.fetch(:repo)
        @branch = options.fetch(:branch)
        @payload = options.fetch(:payload)
        @logger = options.fetch(:logger) { Logger.new(STDOUT) }
      end

      def execute
        github_repo_name = repo.name
        github_config_branch = repo.branch || 'master'

        unless github_config_branch.include?('tags/')
          github_config_branch = "heads/#{github_config_branch}"
        end

        # Check if the branch in the hook data is the configured branch we want
        logger.info("request github branch: #{branch}")
        logger.info("config github branch: #{github_config_branch}")

        if branch.include?(github_config_branch) || branch.include?('L10N')
          logger.info('found branch in github request')

          # Build an index of known Tx resources, by source file
          tx_resources = {}
          project.resources.each do |resource|
            logger.info('processing resource')
            tx_resources[resource.source_file] = resource
          end

          # Find the updated resources and maps the most recent commit in which
          # each was modified
          updated_resources = {}
          payload['commits'].each do |commit|
            logger.info('processing commit')

            commit['modified'].each do |modified|
              logger.info("processing modified file: #{modified}")

              if tx_resources.include?(modified)
                updated_resources[tx_resources[modified]] = commit['id']
              end
            end
          end

          # Handle DBZ 'L10N' special case
          if branch.include?("L10N")
            logger.info('processing L10N tag')

            # Create a new branch off tag commit
            if branch.include?('refs/tags/L10N')
              repo.api.create_ref(repo.name, 'heads/L10N', payload['head_commit']['id'])
            end

            # Create new resources that include 'L10N'
            payload['head_commit']['modified'].each do |modified|
              logger.info("setting new resource: #{tx_resources[modified].L10N_resource_slug}")

              if tx_resources.include?(modified)
                updated_resources[tx_resources[modified]] = payload['head_commit']['id']
              end
            end
          end

          if github_config_branch.include?('tags/')
            payload['head_commit']['modified'].each do |modified|
              logger.info("processing modified file: #{modified}")

              if tx_resources.include?(modified)
                updated_resources[tx_resources[modified]] = payload['head_commit']['id']
              end
            end
          end

          # For each modified resource, get its content and updates the content
          # in Transifex.
          updated_resources.each do |tx_resource, commit_sha|
            logger.info('process updated resource')
            github_api = repo.api
            tree_sha = github_api.get_commit(github_repo_name, commit_sha)['commit']['tree']['sha']
            tree = github_api.tree(github_repo_name, tree_sha)

            tree['tree'].each do |file|
              logger.info("process each tree entry: #{file['path']}")

              if tx_resource.source_file == file['path']
                logger.info("process resource file: #{tx_resource.source_file}")
                blob = github_api.blob(github_repo_name, file['sha'])
                content = blob['encoding'] == 'utf-8' ? blob['content'] : Base64.decode64(blob['content'])
                project.api.update(tx_resource, content)
                logger.info "updated tx_resource: #{tx_resource.inspect}"
              end
            end
          end

          200
        end
      end
    end
  end
end
