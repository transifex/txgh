require 'forwardable'

module Txgh
  class TxBranchResource
    extend Forwardable

    def_delegators :@resource, *[
      :project_slug, :type, :source_lang, :source_file, :L10N_resource_slug,
      :translation_file, :lang_map, :translation_path
    ]

    attr_reader :resource, :branch

    class << self
      def find(tx_config, resource_slug, branch)
        suffix = "-#{Utils.slugify(branch)}"

        if resource_slug.end_with?(suffix)
          resource_slug = resource_slug.chomp(suffix)

          if resource = tx_config.resource(resource_slug)
            new(resource, branch)
          end
        end
      end
    end

    def initialize(resource, branch)
      @resource = resource
      @branch = branch
    end

    def resource_slug
      "#{resource.resource_slug}-#{slugified_branch}"
    end

    def slugs
      [project_slug, resource_slug]
    end

    private

    def slugified_branch
      Utils.slugify(branch)
    end
  end
end
