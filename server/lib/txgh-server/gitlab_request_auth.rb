module TxghServer
  class GitlabRequestAuth < TxghServer::GithubRequestAuth
    RACK_HEADER = 'HTTP_X_GITLAB_SIGNATURE'
    GITLAB_HEADER = 'X-Gitlab-Signature'
  end
end
