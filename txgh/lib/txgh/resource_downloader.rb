require 'octokit'

module Txgh
  class ResourceDownloader
    include Enumerable

    attr_reader :project, :repo, :branch

    def initialize(project, repo, branch, options = {})
      @project = project
      @repo = repo
      @branch = branch

      # Provides an override list of languages. If not present, the downloader
      # will make an API call to fetch the list of languages for the project.
      @languages = options[:languages]
      @resources = options[:resources]
    end

    def each(&block)
      enum.each(&block)
    end

    private

    def enum
      if repo.upload_diffs?
        download_merging_diff
      else
        download_without_diff
      end
    end

    def download_merging_diff
      return to_enum(__method__) unless block_given?

      download_each do |head_resource, language_code, file_name|
        diff_point_resource = tx_config.resource(
          head_resource.original_resource_slug, repo.diff_point
        )

        source_diff = source_diff_hash(head_resource, diff_point_resource)
        head_content = wrap(transifex_download(head_resource, language_code), head_resource)
        diff_point_content = wrap(transifex_download(diff_point_resource, language_code), diff_point_resource)
        contents = diff_point_content.merge(head_content, source_diff)
        contents.serialization_options = Txgh::Utils.deep_symbolize_keys(project.serialization_options)

        yield file_name, contents.to_s(language_code)
      end
    end

    def source_diff_hash(head_resource, diff_point_resource)
      cache_diff(head_resource, diff_point_resource) do
        br = repo.process_all_branches? ? branch : repo.branch
        head_contents = wrap(git_download(head_resource, br), head_resource)
        diff_point_contents = wrap(git_download(diff_point_resource, repo.diff_point), head_resource)
        head_contents.diff_hash(diff_point_contents)
      end
    end

    def cache_diff(head_resource, diff_point_resource)
      key = "#{head_resource.resource_slug}|#{diff_point_resource.resource_slug}"
      if diff = diff_cache[key]
        diff
      else
        diff_cache[key] = yield
      end
    end

    def diff_cache
      @diff_cache ||= {}
    end

    def download_without_diff
      return to_enum(__method__) unless block_given?

      download_each do |resource, language_code, file_name|
        contents = transifex_download(resource, language_code)
        yield file_name, contents
      end
    end

    def download_each
      each_resource do |resource|
        each_language do |language_code|
          file_name = resource.translation_path(language_code)
          yield resource, language_code, file_name
        end
      end
    end

    def wrap(string, resource)
      if string
        ResourceContents.from_string(resource, string)
      else
        EmptyResourceContents.new(resource)
      end
    end

    def transifex_download(resource, language)
      transifex_api.download(resource, language)
    rescue TransifexNotFoundError
      # return nil here so wrap() will return an instance of EmptyResourceContents
      nil
    end

    def git_download(resource, branch)
      repo.api.download(resource.source_file, branch)[:content]
    rescue Octokit::NotFound
      # return nil here so wrap() will return an instance of EmptyResourceContents
      nil
    end

    def transifex_api
      project.api
    end

    def each_resource(&block)
      return to_enum(__method__) unless block_given?
      return @resources.each(&block) if @resources

      ref = repo.process_all_branches? ? branch : nil

      tx_config.resources.each do |res|
        yield tx_config.resource(res.resource_slug, ref)
      end
    end

    def each_language(&block)
      return to_enum(__method__) unless block_given?
      return @languages.each(&block) if @languages

      project.languages.each(&block)
    end

    def tx_config
      @tx_config ||= Txgh::Config::TxManager.tx_config(
        project, repo, repo.process_all_branches? ? branch : repo.branch
      )
    end
  end
end
