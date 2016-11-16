module Txgh
  class TxResource
    attr_reader :project_slug, :resource_slug, :type, :source_lang
    attr_reader :source_file, :translation_file

    alias_method :original_resource_slug, :resource_slug

    def initialize(project_slug, resource_slug, type, source_lang, source_file,
        lang_map, translation_file)
      @project_slug = project_slug
      @resource_slug = resource_slug
      @type = type
      @source_lang = source_lang
      @source_file = source_file
      @lang_map = lang_map
      @translation_file = translation_file
    end

    def lang_map(tx_lang)
      @lang_map.fetch(tx_lang, tx_lang)
    end

    def translation_path(language)
      translation_file.gsub('<lang>', lang_map(language))
    end

    def slugs
      [project_slug, resource_slug]
    end

    def to_h
      {
        project_slug: project_slug,
        resource_slug: resource_slug,
        type: type,
        source_lang: source_lang,
        source_file: source_file,
        translation_file: translation_file
      }
    end

    def to_api_h
      {
        'slug' => resource_slug,
        'i18n_type' => type,
        'source_language_code' => source_lang,
        'name' => translation_file
      }
    end

    def branch
      nil
    end

    def has_branch?
      false
    end
  end
end
