module TxghServer
  class DownloadHandler
    DEFAULT_FORMAT = '.zip'

    # includes response helpers in both the class and the singleton class
    include ResponseHelpers

    class << self
      def handle_request(request, logger = nil)
        handle_safely do
          config = config_from(request)
          project, repo = [config.transifex_project, config.git_repo]
          params = params_from(request)
          handler = new(project, repo, params, logger)
          handler.execute
        end
      end

      private

      def config_from(request)
        Txgh::Config::KeyManager.config_from_project(
          request.params.fetch('project_slug')
        )
      end

      def params_from(request)
        request.params.merge(
          'format' => format_from(request)
        )
      end

      def format_from(request)
        # sinatra is dumb and doesn't include any of the URL captures in the
        # request params or env hash
        File.extname(request.env['REQUEST_PATH'])
      end

      def handle_safely
        yield
      rescue => e
        respond_with_error(500, "Internal server error: #{e.message}", e)
      end
    end

    attr_reader :project, :repo, :params, :logger

    def initialize(project, repo, params, logger)
      @project = project
      @repo = repo
      @params = params
      @logger = logger
    end

    def execute
      downloader = Txgh::ResourceDownloader.new(
        project, repo, params['branch'], languages: project.languages
      )

      response_class.new(attachment, downloader.each)
    end

    private

    def attachment
      project.name
    end

    def format
      params.fetch('format', DEFAULT_FORMAT)
    end

    def response_class
      case format
        when '.zip'
          ZipStreamResponse
        when '.tgz'
          TgzStreamResponse
        else
          raise TxghInternalError,
            "'#{format}' is not a valid download format"
      end
    end
  end
end
