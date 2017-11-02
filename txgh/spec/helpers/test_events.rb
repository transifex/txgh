class TestEvents < Txgh::Events
  attr_reader :published

  def initialize
    @published = []
    super
  end

  def publish(channel, options = {})
    published << { channel: channel, options: options }
    super
  end

  def published_in(channel)
    published.select { |event| event[:channel] == channel }
  end
end
