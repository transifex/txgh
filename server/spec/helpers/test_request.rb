class TestRequest
  attr_reader :body, :params, :headers, :request_method
  alias_method :env, :headers

  def initialize(body: , params: {}, headers: {}, request_method: 'POST')
    @body = StringIO.new(body)
    @params = params
    @headers = headers
    @request_method = request_method
  end
end
