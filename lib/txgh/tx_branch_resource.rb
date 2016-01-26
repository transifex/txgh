require 'forwardable'

module Txgh
  class TxBranchResource
    extend Forwardable

    def_delegators :@resource, *[
      :project_slug, :resource_slug, :type, :source_lang,
      :source_file, :translation_file, :lang_map, :translation_path
    ]

    attr_reader :resource, :branch

    class << self
      def find(project, resource_slug, branch)
        suffix = "-#{Utils.slugify(branch)}"

        if resource_slug.end_with?(suffix)
          resource_slug = resource_slug.chomp(suffix)
          new(project.resource(resource_slug), branch)
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

    private

    def slugified_branch
      Utils.slugify(branch)
    end
  end
end
