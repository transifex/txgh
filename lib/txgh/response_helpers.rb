module Txgh
  module ResponseHelpers
    private

    def respond_with(status, body)
      Txgh::Handlers::Response.new(status, body)
    end

    def respond_with_success(status, body)
      respond_with(status, data(body))
    end

    def respond_with_error(status, message)
      respond_with(status, error(message))
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
