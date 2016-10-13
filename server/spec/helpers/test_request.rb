class TestRequest
  attr_reader :body, :params, :headers
  alias_method :env, :headers

  def initialize(body: , params: {}, headers: {})
    @body = StringIO.new(body)
    @params = params
    @headers = headers
  end
end
