module Txgh
  module Config
    class TxConfig
      class << self
        def load_file(path)
          config = Txgh::ParseConfig.load_file(path)
          load_config(config)
        end

        def load(contents)
          config = Txgh::ParseConfig.load(contents)
          load_config(config)
        end

        private

        def load_config(config)
          lang_map = load_lang_map(config)
          resources = load_resources(config, lang_map)
          new(resources, lang_map)
        end

        def load_lang_map(config)
          lang_map = if main = config['main']
            if map = main['lang_map']
              parse_lang_map(map)
            end
          end

          lang_map || {}
        end

        def load_resources(config, lang_map)
          [].tap do |resources|
            config.groups.each do |group|
              next if group == 'main'
              resources << load_resource(group, config[group], lang_map)
            end
          end
        end

        def parse_lang_map(lang_map)
          lang_map.split(',').each_with_object({}) do |m, result|
            key_value = m.split(':', 2)
            result[key_value[0].strip] = key_value[1].strip
          end
        end

        def load_resource(name, resource, lang_map)
          id = name.split('.', 2)
          TxResource.new(
            id[0].strip, id[1].strip, resource['type'],
            resource['source_lang'], resource['source_file'],
            lang_map, resource['file_filter']
          )
        end
      end

      attr_reader :resources, :lang_map

      def initialize(resources, lang_map)
        @resources = resources
        @lang_map = lang_map
      end

      def resource(slug, branch = nil)
        if branch
          TxBranchResource.find(self, slug, branch)
        else
          resources.find do |resource|
            resource.resource_slug == slug
          end
        end
      end

      def to_h
        { resources: resources.map(&:to_h), lang_map: lang_map }
      end
    end
  end
end
