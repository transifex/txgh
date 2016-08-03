module Txgh
  module ResponseHelpers
    private

    def respond_with(status, body, e = nil)
      Txgh::Handlers::Response.new(status, body, e)
    end

    def respond_with_error(status, message, e = nil)
      respond_with(status, error(message), e)
    end

    def error(message)
      [{ error: message }]
    end

    def data(body)
      { data: body }
    end

    # includes these methods in the singleton class as well
    def self.included(base)
      base.extend(self)
    end
  end
end
