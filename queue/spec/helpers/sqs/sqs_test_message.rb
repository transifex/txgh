require 'securerandom'

class SqsTestMessage
  attr_reader :message_id, :body, :message_attributes
  attr_reader :receipt_handle

  def initialize(message_id, body, message_attributes = {})
    @message_id = message_id
    @body = body
    @message_attributes = SqsTestMessageAttributes.new(message_attributes)
    @receipt_handle = SecureRandom.hex
  end

  def to_bundle
    SqsTestMessageBundle.new([self])
  end
end

class SqsTestMessageBundle
  attr_reader :messages

  def initialize(messages)
    @messages = messages
  end
end

class SqsTestMessageAttributes
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  def [](key)
    if attribute = attributes[key]
      SqsTestMessageAttribute.new(attribute)
    end
  end
end

class SqsTestMessageAttribute
  attr_reader :string_value

  def initialize(attribute)
    @string_value = attribute['string_value']
  end
end
