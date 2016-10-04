require 'celluloid/current'

module Txgh
  class GithubStatus
    class State
      PENDING = 'pending'
      SUCCESS = 'success'
      ERROR   = 'error'
      FAILURE = 'failure'

      class << self
        def pending; PENDING; end
        def success; SUCCESS; end
        def error; ERROR; end
        def failure; failure; end
      end
    end

    ALL_COMPLETE_DESCRIPTION = "Translations complete!"
    TARGET_URL_TEMPLATE = "https://www.transifex.com/%{organization}/%{project_slug}/content"
    DESCRIPTION_TEMPLATE = "%{complete}/%{total} translations complete."
    CONTEXT = 'continuous-localization/txgh'

    class << self
      def update(project, repo, branch)
        new(project, repo, branch).update
      end
    end

    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch)
      @project = project
      @repo = repo
      @branch = branch
    end

    def update
      return if tx_resources.empty?

      sha = repo.api.get_ref(branch)[:object][:sha]

      repo.api.create_status(
        sha, state, {
          context: context, target_url: target_url, description: description
        }
      )
    end

    private

    def context
      CONTEXT
    end

    def target_url
      # assume all resources are from the same project
      TARGET_URL_TEMPLATE % {
        organization: project.organization,
        project_slug: tx_resources.first.project_slug
      }
    end

    def state
      if all_complete?
        State.success
      else
        State.pending
      end
    end

    def description
      if all_complete?
        ALL_COMPLETE_DESCRIPTION
      else
        DESCRIPTION_TEMPLATE % stat_totals
      end
    end

    def all_complete?
      stats.all? do |resource_stats|
        resource_stats.all? do |locale, details|
          details['completed'] == '100%'
        end
      end
    end

    def stat_totals
      @stat_totals ||= { complete: 0, total: 0 }.tap do |counts|
        stats.each do |resource_stats|
          resource_stats.each_pair do |locale, details|
            counts[:total] += details['translated_entities'] + details['untranslated_entities']
            counts[:complete] += details['translated_entities']
          end
        end
      end
    end

    def stats
      @stats ||= tx_resources.map do |tx_resource|
        Celluloid::Future.new { project.api.get_stats(*tx_resource.slugs) }
      end.map(&:value)
    end

    def tx_resources
      @tx_resources ||=
        tx_config.resources.each_with_object([]) do |tx_resource, ret|
          if repo.process_all_branches?
            tx_resource = Txgh::TxBranchResource.new(tx_resource, branch)
          end

          next unless existing_slugs.include?(tx_resource.resource_slug)
          ret << tx_resource
        end
    end

    def existing_slugs
      @existing_slugs ||= existing_resources.map do |resource|
        resource['slug']
      end
    end

    def existing_resources
      @existing_resources ||= project.api.get_resources(project.name)
    end

    def tx_config
      @tx_config ||= Txgh::Config::TxManager.tx_config(project, repo, branch)
    end
  end
end
