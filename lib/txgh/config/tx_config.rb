module Txgh
  module Config
    class TxConfig
      class << self
        def load_file(path)
          config = Txgh::ParseConfig.load_file(path)
          parse(config)
        end

        def load(contents)
          config = Txgh::ParseConfig.load(contents)
          parse(config)
        end

        private

        def parse(config)
          resources = []
          lang_map = {}

          config.get_groups.each do |group|
            if group == 'main'
              main = config[group]

              if main['lang_map']
                lang_map = parse_lang_map(main['lang_map'])
              end
            else
              resources.push(
                parse_resource(group, config[group])
              )
            end
          end

          new(resources, lang_map)
        end

        def parse_lang_map(lang_map)
          lang_map.split(',').each_with_object({}) do |m, result|
            key_value = m.split(':', 2)
            result[key_value[0].strip] = key_value[1].strip
          end
        end

        def parse_resource(name, resource)
          id = name.split('.', 2)
          TxResource.new(
            id[0].strip, id[1].strip, resource['type'],
            resource['source_lang'], resource['source_file'],
            resource['lang_map'], resource['file_filter']
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
