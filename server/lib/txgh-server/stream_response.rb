require 'mime/types'

module TxghServer
  class StreamResponse
    attr_reader :attachment, :enum

    def initialize(attachment, enum)
      @attachment = attachment
      @enum = enum
    end

    def write_to(stream)
      raise NotImplementedError,
        "please implement #{__method__} in derived classes"
    end

    def file_extension
      raise NotImplementedError,
        "please implement #{__method__} in derived classes"
    end

    def headers
      @headers ||= {
        'Content-Disposition' => "attachment; filename=\"#{attachment}#{file_extension}\"",
        'Content-Type' => MIME::Types.type_for(file_extension).first.content_type
      }
    end

    def streaming?
      true
    end

    def error
      nil
    end
  end
end
