class TestEvents < Txgh::Events
  attr_reader :published

  def initialize
    @published = []
    super
  end

  def publish(channel, options = {})
    published << { channel: channel, options: options }
  end
end
