module Txgh
  class Events
    ERROR_CHANNEL = 'errors'

    attr_reader :channel_hash

    def initialize
      @channel_hash = Hash.new { |h, k| h[k] = [] }
    end

    def subscribe(channel, &block)
      channel_hash[channel] << block
    end

    def publish(channel, options = {})
      channel_hash.fetch(channel, []).each do |callback|
        result = callback.call(options)
        yield result if block_given?
      end
    rescue => e
      publish_error!(e)
    end

    alias_method :publish_each, :publish

    def channels
      channel_hash.keys
    end

    def publish_error(e, params = {})
      callbacks = channel_hash.fetch(ERROR_CHANNEL) { [] }
      callbacks.map { |callback| callback.call(e, params) }
    end

    def publish_error!(e, params = {})
      # if nobody has subscribed to error events, raise original error
      callbacks = channel_hash.fetch(ERROR_CHANNEL) { raise e }
      callbacks.map { |callback| callback.call(e, params) }
    end
  end
end
