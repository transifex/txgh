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
    TARGET_URL_TEMPLATE = "https://www.transifex.com/%{organization}/%{project_slug}/%{resource_slug}/"
    DESCRIPTION_TEMPLATE = "%{complete}/%{total} translations complete."
    CONTEXT = 'continuous-localization/txgh'

    attr_reader :project, :repo, :tx_resource

    def initialize(project, repo, tx_resource)
      @project = project
      @repo = repo
      @tx_resource = tx_resource
    end

    def update(sha)
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
      TARGET_URL_TEMPLATE % {
        organization: project.organization,
        project_slug: tx_resource.project_slug,
        resource_slug: tx_resource.resource_slug
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
      stats.all? do |locale, details|
        details['completed'] == '100%'
      end
    end

    def stat_totals
      @stat_totals ||= { complete: 0, total: 0 }.tap do |counts|
        stats.each_pair do |locale, details|
          counts[:total] += details['translated_entities'] + details['untranslated_entities']
          counts[:complete] += details['translated_entities']
        end
      end
    end

    def stats
      @stats ||= project.api.get_stats(*tx_resource.slugs)
    end
  end
end
