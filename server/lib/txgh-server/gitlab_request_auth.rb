module TxghServer
  class GitlabRequestAuth
    RACK_HEADER = 'HTTP_X_GITLAB_TOKEN'
    GITLAB_HEADER = 'X-Gitlab-Token'

    class << self
      def authentic_request?(request, secret)
        request_token = request.env[RACK_HEADER]
        request_token == secret
      end
    end
  end
end
