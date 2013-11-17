module Strava
  module L10n
    class TxResource
      def initialize(project_slug, resource_slug, type, source_lang, source_file,
          translation_file)
        @project_slug = project_slug
        @resource_slug = resource_slug
        @type = type
        @source_lang = source_lang
        @source_file = source_file
        @translation_file = translation_file
      end

      def project_slug
        @project_slug
      end

      def resource_slug
        @resource_slug
      end

      def type
        @type
      end

      def source_lang
        @source_lang
      end

      def source_file
        @source_file
      end

      def translation_path(language)
        path = String.new(@translation_file)
        path['<lang>'] = language
        path
      end

    end
  end
end
